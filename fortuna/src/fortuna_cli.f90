! SPDX-License-Identifier: AGPL-3.0-or-later
! fortuna_cli -- argument parsing and command dispatch.
module fortuna_cli
   use fortuna_kinds, only: dp
   use fortuna_sim, only: sim_config, sim_result, run_simulation, &
                          solve_safe_spend, validate_config
   use fortuna_report, only: print_report, write_csv, money, pct
   use fortuna_http, only: http_serve
   use fortuna_json, only: jr, jr4, json_real_array
   use fortuna_forms, only: i2s
   implicit none
   private
   public :: run_cli

   character(*), parameter :: version = '0.1.0'

contains

   subroutine run_cli()
      character(:), allocatable :: cmd, arg, val, csv_path, host, webroot, err
      type(sim_config) :: cfg
      type(sim_result) :: res
      real(dp) :: target, solved, achieved
      integer :: nargs, i, port
      logical :: json_out, ok

      csv_path = ''
      host = '127.0.0.1'
      webroot = ''
      port = 8080
      target = 0.90_dp
      json_out = .false.

      nargs = command_argument_count()
      cmd = 'simulate'
      i = 1
      if (nargs >= 1) then
         arg = get_arg(1)
         if (arg(1:2) /= '--') then
            cmd = arg
            i = 2
         end if
      end if

      select case (cmd)
      case ('help', '-h', '--help')
         call print_help(); return
      case ('version', '-v', '--version')
         print '(a)', 'fortuna '//version; return
      case ('simulate', 'serve', 'spend')
         ! fall through to option parsing
      case default
         print '(a)', 'fortuna: unknown command "'//cmd//'" (try: fortuna help)'
         stop 1
      end select

      do while (i <= nargs)
         arg = get_arg(i)
         select case (arg)
         case ('--json')
            json_out = .true.
            i = i + 1
         case ('--help', '-h')
            call print_help(); return
         case default
            if (i + 1 > nargs) then
               print '(a)', 'fortuna: option '//arg//' needs a value'
               stop 1
            end if
            val = get_arg(i + 1)
            call apply_option(arg, val, cfg, csv_path, host, webroot, port, target)
            i = i + 2
         end select
      end do

      err = validate_config(cfg)
      if (len(err) > 0) then
         print '(a)', 'fortuna: '//err
         stop 1
      end if

      select case (cmd)
      case ('serve')
         call http_serve(host, port, cfg, webroot)

      case ('spend')
         call solve_safe_spend(cfg, target, solved, achieved)
         cfg%annual_spend = solved
         call run_simulation(cfg, res)
         if (json_out) then
            print '(a)', '{"solved_spend":'//jr(solved)// &
               ',"solved_monthly":'//jr(solved/12.0_dp)// &
               ',"target":'//jr4(target)// &
               ',"success_rate":'//jr4(res%success_rate)//'}'
         else
            print '(a)', ''
            print '(a)', '  highest sustainable retirement spending at a '// &
               pct(target)//' success target:'
            print '(a)', ''
            print '(a)', '    '//money(solved)//' per year  ('// &
               money(solved/12.0_dp)//' per month, today''s dollars)'
            print '(a)', ''
            call print_report(cfg, res)
         end if

      case default   ! simulate
         call run_simulation(cfg, res)
         if (json_out) then
            print '(a)', '{"success_rate":'//jr4(res%success_rate)// &
               ',"ages":'//json_real_array(res%ages)// &
               ',"p05":'//json_real_array(res%p05)// &
               ',"p25":'//json_real_array(res%p25)// &
               ',"p50":'//json_real_array(res%p50)// &
               ',"p75":'//json_real_array(res%p75)// &
               ',"p95":'//json_real_array(res%p95)// &
               ',"median_end":'//jr(res%median_end)// &
               ',"median_at_retirement":'//jr(res%median_at_retirement)//'}'
         else
            call print_report(cfg, res)
         end if
         if (len(csv_path) > 0) then
            call write_csv(csv_path, res, ok)
            if (ok) then
               print '(a)', '  wrote '//csv_path
            else
               print '(a)', 'fortuna: could not write '//csv_path
               stop 1
            end if
         end if
      end select
   end subroutine run_cli

   subroutine apply_option(arg, val, cfg, csv_path, host, webroot, port, target)
      character(*), intent(in) :: arg, val
      type(sim_config), intent(inout) :: cfg
      character(:), allocatable, intent(inout) :: csv_path, host, webroot
      integer, intent(inout) :: port
      real(dp), intent(inout) :: target

      select case (arg)
      case ('--age'); cfg%current_age = to_real(val, arg)
      case ('--retire-age', '--retire'); cfg%retire_age = to_real(val, arg)
      case ('--end-age', '--until'); cfg%end_age = to_real(val, arg)
      case ('--balance'); cfg%balance0 = to_real(val, arg)
      case ('--monthly'); cfg%monthly_contrib = to_real(val, arg)
      case ('--contrib-growth'); cfg%contrib_growth = to_real(val, arg)/100.0_dp
      case ('--return'); cfg%annual_return = to_real(val, arg)/100.0_dp
      case ('--vol'); cfg%annual_vol = to_real(val, arg)/100.0_dp
      case ('--spend'); cfg%annual_spend = to_real(val, arg)
      case ('--pension'); cfg%pension_monthly = to_real(val, arg)
      case ('--pension-age'); cfg%pension_age = to_real(val, arg)
      case ('--paths'); cfg%n_paths = nint(to_real(val, arg))
      case ('--seed'); cfg%seed = nint(to_real(val, arg))
      case ('--target'); target = to_real(val, arg)/100.0_dp
      case ('--csv'); csv_path = val
      case ('--port'); port = nint(to_real(val, arg))
      case ('--host'); host = val
      case ('--webroot'); webroot = val
      case default
         print '(a)', 'fortuna: unknown option '//arg//' (try: fortuna help)'
         stop 1
      end select
   end subroutine apply_option

   function to_real(val, opt) result(x)
      character(*), intent(in) :: val, opt
      real(dp) :: x
      integer :: ios

      read (val, *, iostat=ios) x
      if (ios /= 0) then
         print '(a)', 'fortuna: could not read a number for '//opt//': "'//val//'"'
         stop 1
      end if
   end function to_real

   function get_arg(k) result(s)
      integer, intent(in) :: k
      character(:), allocatable :: s
      integer :: l

      call get_command_argument(k, length=l)
      allocate (character(l) :: s)
      call get_command_argument(k, value=s)
   end function get_arg

   subroutine print_help()
      print '(a)', ''
      print '(a)', 'fortuna '//version//' -- Monte Carlo wealth forecaster, full-stack Fortran'
      print '(a)', ''
      print '(a)', 'usage: fortuna [command] [options]'
      print '(a)', ''
      print '(a)', 'commands:'
      print '(a)', '  simulate         run a forecast and print percentile bands (default)'
      print '(a)', '  spend            solve for the highest sustainable retirement spending'
      print '(a)', '  serve            start the local web UI (pure-Fortran HTTP server)'
      print '(a)', '  help, version'
      print '(a)', ''
      print '(a)', 'plan options (all values in today''s dollars; rates in percent):'
      print '(a)', '  --age N              current age                        [30]'
      print '(a)', '  --retire-age N       retirement age                     [65]'
      print '(a)', '  --end-age N          plan until this age                [95]'
      print '(a)', '  --balance X          current invested savings           [25000]'
      print '(a)', '  --monthly X          monthly contribution               [500]'
      print '(a)', '  --contrib-growth P   contribution growth, %/yr          [1]'
      print '(a)', '  --return P           expected REAL return, %/yr         [5]'
      print '(a)', '  --vol P              annual volatility, %               [15]'
      print '(a)', '  --spend X            retirement spending, $/yr          [40000]'
      print '(a)', '  --pension X          pension / Social Security, $/mo    [0]'
      print '(a)', '  --pension-age N      pension starting age               [67]'
      print '(a)', ''
      print '(a)', 'engine options:'
      print '(a)', '  --paths N            Monte Carlo paths                  [10000]'
      print '(a)', '  --seed N             RNG seed (>0 = reproducible)       [random]'
      print '(a)', '  --target P           success target for `spend`, %     [90]'
      print '(a)', ''
      print '(a)', 'output options:'
      print '(a)', '  --json               print results as JSON'
      print '(a)', '  --csv FILE           also write yearly percentiles as CSV'
      print '(a)', ''
      print '(a)', 'server options:'
      print '(a)', '  --port N             listen port                        [8080]'
      print '(a)', '  --host A             bind address                       [127.0.0.1]'
      print '(a)', '  --webroot DIR        serve DIR/index.html from disk instead of the'
      print '(a)', '                       embedded page (useful when hacking on the UI)'
      print '(a)', ''
      print '(a)', 'examples:'
      print '(a)', '  fortuna --age 35 --balance 80000 --monthly 900 --spend 45000'
      print '(a)', '  fortuna spend --age 40 --balance 300000 --retire-age 60 --target 95'
      print '(a)', '  fortuna serve --port 8080'
      print '(a)', ''
      print '(a)', 'Everything is computed in real (inflation-adjusted) terms, so use a'
      print '(a)', 'REAL expected return. This is a modelling toy, not financial advice.'
      print '(a)', ''
   end subroutine print_help

end module fortuna_cli
