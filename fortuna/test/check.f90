! SPDX-License-Identifier: AGPL-3.0-or-later
! check -- fortuna's test suite. Exits non-zero on the first failure.
program check
   use fortuna_kinds, only: dp
   use fortuna_sim, only: sim_config, sim_result, run_simulation, &
                          solve_safe_spend, validate_config, percentile
   use fortuna_forms, only: url_decode, form_get_real, form_get_str, form_get_int
   use fortuna_report, only: money
   use fortuna_json, only: jr, json_real_array
   implicit none

   integer :: nfail
   nfail = 0

   call t_deterministic_growth()
   call t_contributions_zero_return()
   call t_no_spending_always_succeeds()
   call t_impossible_spending_always_fails()
   call t_percentiles_monotone()
   call t_reproducible_seed()
   call t_solver_hits_target()
   call t_url_decode()
   call t_form_parsing()
   call t_money_format()
   call t_json_format()
   call t_validation()

   if (nfail > 0) then
      print '(a,i0,a)', 'FAILED: ', nfail, ' test(s)'
      stop 1
   end if
   print '(a)', 'all tests passed'

contains

   subroutine expect(cond, name)
      logical, intent(in) :: cond
      character(*), intent(in) :: name

      if (cond) then
         print '(a)', '  ok    '//name
      else
         print '(a)', '  FAIL  '//name
         nfail = nfail + 1
      end if
   end subroutine expect

   !> With zero volatility and no cash flows the model must reproduce
   !> deterministic compound growth exactly: B = B0 * (1+R)^years.
   subroutine t_deterministic_growth()
      type(sim_config) :: cfg
      type(sim_result) :: res
      real(dp) :: expected

      cfg%current_age = 30.0_dp
      cfg%retire_age = 60.0_dp
      cfg%end_age = 60.0_dp
      cfg%balance0 = 1000.0_dp
      cfg%monthly_contrib = 0.0_dp
      cfg%annual_return = 0.05_dp
      cfg%annual_vol = 0.0_dp
      cfg%annual_spend = 0.0_dp
      cfg%n_paths = 100
      cfg%seed = 1
      call run_simulation(cfg, res)
      expected = 1000.0_dp*1.05_dp**30
      call expect(abs(res%p50(res%n_years) - expected)/expected < 1.0e-9_dp, &
                  'zero-vol growth matches closed form')
   end subroutine t_deterministic_growth

   !> Zero return, zero vol: the final balance is exactly the sum of
   !> contributions plus the opening balance.
   subroutine t_contributions_zero_return()
      type(sim_config) :: cfg
      type(sim_result) :: res
      real(dp) :: expected

      cfg%current_age = 30.0_dp
      cfg%retire_age = 40.0_dp
      cfg%end_age = 40.0_dp
      cfg%balance0 = 500.0_dp
      cfg%monthly_contrib = 100.0_dp
      cfg%contrib_growth = 0.0_dp
      cfg%annual_return = 0.0_dp
      cfg%annual_vol = 0.0_dp
      cfg%annual_spend = 0.0_dp
      cfg%n_paths = 100
      cfg%seed = 1
      call run_simulation(cfg, res)
      expected = 500.0_dp + 100.0_dp*12.0_dp*10.0_dp
      call expect(abs(res%p50(res%n_years) - expected) < 1.0e-6_dp, &
                  'contributions add up at zero return')
   end subroutine t_contributions_zero_return

   subroutine t_no_spending_always_succeeds()
      type(sim_config) :: cfg
      type(sim_result) :: res

      cfg%annual_spend = 0.0_dp
      cfg%n_paths = 2000
      cfg%seed = 7
      call run_simulation(cfg, res)
      call expect(abs(res%success_rate - 1.0_dp) < tiny(1.0_dp), 'zero spending never fails')
   end subroutine t_no_spending_always_succeeds

   subroutine t_impossible_spending_always_fails()
      type(sim_config) :: cfg
      type(sim_result) :: res

      cfg%balance0 = 1000.0_dp
      cfg%monthly_contrib = 0.0_dp
      cfg%annual_spend = 1.0e7_dp
      cfg%pension_monthly = 0.0_dp
      cfg%n_paths = 500
      cfg%seed = 7
      call run_simulation(cfg, res)
      call expect(abs(res%success_rate) < tiny(1.0_dp), 'absurd spending always fails')
   end subroutine t_impossible_spending_always_fails

   subroutine t_percentiles_monotone()
      type(sim_config) :: cfg
      type(sim_result) :: res
      logical :: ok
      integer :: y

      cfg%n_paths = 2000
      cfg%seed = 42
      call run_simulation(cfg, res)
      ok = .true.
      do y = 0, res%n_years
         if (res%p05(y) > res%p25(y) .or. res%p25(y) > res%p50(y) .or. &
             res%p50(y) > res%p75(y) .or. res%p75(y) > res%p95(y)) ok = .false.
      end do
      call expect(ok, 'percentile bands are ordered')
   end subroutine t_percentiles_monotone

   subroutine t_reproducible_seed()
      type(sim_config) :: cfg
      type(sim_result) :: r1, r2

      cfg%n_paths = 1000
      cfg%seed = 12345
      call run_simulation(cfg, r1)
      call run_simulation(cfg, r2)
      call expect(all(abs(r1%p50 - r2%p50) < 1.0e-12_dp) .and. &
                  abs(r1%success_rate - r2%success_rate) < tiny(1.0_dp), &
                  'same seed reproduces the same result')
   end subroutine t_reproducible_seed

   subroutine t_solver_hits_target()
      type(sim_config) :: cfg
      real(dp) :: spend, achieved

      cfg%current_age = 40.0_dp
      cfg%retire_age = 65.0_dp
      cfg%end_age = 90.0_dp
      cfg%balance0 = 200000.0_dp
      cfg%monthly_contrib = 800.0_dp
      cfg%n_paths = 2000
      cfg%seed = 9
      call solve_safe_spend(cfg, 0.90_dp, spend, achieved)
      call expect(spend > 0.0_dp .and. achieved >= 0.90_dp .and. achieved <= 1.0_dp, &
                  'spending solver meets its success target')
   end subroutine t_solver_hits_target

   subroutine t_url_decode()
      call expect(url_decode('a%20b+c') == 'a b c', 'url_decode handles %XX and +')
      call expect(url_decode('100%25') == '100%', 'url_decode handles percent sign')
   end subroutine t_url_decode

   subroutine t_form_parsing()
      character(:), allocatable :: v
      logical :: found

      call expect(abs(form_get_real('spend=42.5&x=1', 'spend', 0.0_dp) - 42.5_dp) &
                  < 1.0e-12_dp, 'form_get_real reads a value')
      call expect(abs(form_get_real('a=1&b=2', 'zz', 7.0_dp) - 7.0_dp) &
                  < 1.0e-12_dp, 'form_get_real falls back to default')
      call expect(form_get_int('paths=5000&seed=3', 'seed', 0) == 3, &
                  'form_get_int reads an integer')
      v = form_get_str('name=hello%20world&x=1', 'name', found)
      call expect(found .and. v == 'hello world', 'form_get_str decodes values')
      call expect(abs(form_get_real('vol=15%&x=1', 'vol', 0.0_dp) - 15.0_dp) &
                  < 1.0e-12_dp, 'form_get_real tolerates a percent sign')
   end subroutine t_form_parsing

   subroutine t_money_format()
      call expect(money(1234567.0_dp) == '$1,234,567', 'money groups thousands')
      call expect(money(0.0_dp) == '$0', 'money handles zero')
      call expect(money(-2500.0_dp) == '-$2,500', 'money handles negatives')
   end subroutine t_money_format

   subroutine t_json_format()
      real(dp) :: v(3)

      v = [1.0_dp, 2.5_dp, 3.25_dp]
      call expect(jr(0.5_dp) == '0.50', 'jr pads a leading zero')
      call expect(json_real_array(v) == '[1.00,2.50,3.25]', 'json arrays render')
   end subroutine t_json_format

   subroutine t_validation()
      type(sim_config) :: cfg
      character(:), allocatable :: err

      cfg%end_age = 20.0_dp
      cfg%current_age = 30.0_dp
      err = validate_config(cfg)
      call expect(len(err) > 0, 'validation rejects end age before current age')

      cfg = sim_config()
      cfg%retire_age = 200.0_dp
      err = validate_config(cfg)
      call expect(len(err) == 0 .and. cfg%retire_age <= cfg%end_age, &
                  'validation clamps retirement age into the plan window')
   end subroutine t_validation

end program check
