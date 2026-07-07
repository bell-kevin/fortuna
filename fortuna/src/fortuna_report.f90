! SPDX-License-Identifier: AGPL-3.0-or-later
! fortuna_report -- terminal output: pretty money strings, the percentile
! table, and CSV export.
module fortuna_report
   use fortuna_kinds, only: dp, i8
   use fortuna_sim, only: sim_config, sim_result
   use fortuna_forms, only: i2s
   implicit none
   private
   public :: money, print_report, write_csv, pct

contains

   !> 1234567.0 -> "$1,234,567"
   function money(x) result(s)
      real(dp), intent(in) :: x
      character(:), allocatable :: s
      character(40) :: buf
      character(:), allocatable :: digits, grouped
      integer(i8) :: v
      integer :: n, i, cnt

      v = nint(abs(x), i8)
      write (buf, '(i0)') v
      digits = trim(buf)
      n = len(digits)
      grouped = ''
      cnt = 0
      do i = n, 1, -1
         grouped = digits(i:i)//grouped
         cnt = cnt + 1
         if (mod(cnt, 3) == 0 .and. i > 1) grouped = ','//grouped
      end do
      if (x < -0.5_dp) then
         s = '-$'//grouped
      else
         s = '$'//grouped
      end if
   end function money

   !> 0.874 -> "87.4%"
   function pct(x) result(s)
      real(dp), intent(in) :: x
      character(:), allocatable :: s
      character(16) :: buf

      write (buf, '(f0.1)') 100.0_dp*x
      s = trim(adjustl(buf))
      if (s(1:1) == '.') s = '0'//s
      s = s//'%'
   end function pct

   subroutine print_report(cfg, res)
      type(sim_config), intent(in) :: cfg
      type(sim_result), intent(in) :: res
      integer :: y, nb
      character(24) :: bar
      logical :: show

      print '(a)', ''
      print '(a)', '  FORTUNA -- Monte Carlo wealth forecast (all values in today''s dollars)'
      print '(a)', '  ------------------------------------------------------------------------'
      print '(a)', '  paths: '//i2s(cfg%n_paths)//'   horizon: age '// &
         i2s(nint(cfg%current_age))//' -> '//i2s(nint(cfg%end_age))// &
         '   retire at: '//i2s(nint(cfg%retire_age))
      print '(a)', '  real return: '//pct(cfg%annual_return)//'/yr   volatility: '// &
         pct(cfg%annual_vol)//'/yr   retirement spend: '//money(cfg%annual_spend)//'/yr'
      print '(a)', ''

      nb = nint(res%success_rate*24.0_dp)
      nb = min(max(nb, 0), 24)
      bar = repeat('#', nb)//repeat('.', 24 - nb)
      print '(a)', '  success rate: '//pct(res%success_rate)//'  ['//bar//']'
      print '(a)', '  (share of futures where the portfolio was never depleted in retirement)'
      print '(a)', ''

      print '(a)', '   age        5th pct       25th pct         median       75th pct       95th pct'
      print '(a)', '  ------------------------------------------------------------------------------'
      do y = 0, res%n_years
         show = (mod(y, 5) == 0) .or. (y == res%n_years) .or. &
                (nint(res%ages(y)) == nint(cfg%retire_age))
         if (.not. show) cycle
         if (nint(res%ages(y)) == nint(cfg%retire_age) .and. y /= 0 .and. y /= res%n_years) then
            print '(2x,i4,a1,5(1x,a14))', nint(res%ages(y)), '*', &
               rpad(money(res%p05(y))), rpad(money(res%p25(y))), rpad(money(res%p50(y))), &
               rpad(money(res%p75(y))), rpad(money(res%p95(y)))
         else
            print '(2x,i4,1x,5(1x,a14))', nint(res%ages(y)), &
               rpad(money(res%p05(y))), rpad(money(res%p25(y))), rpad(money(res%p50(y))), &
               rpad(money(res%p75(y))), rpad(money(res%p95(y)))
         end if
      end do
      print '(a)', '  (* = retirement age)'
      print '(a)', ''
      print '(a)', '  median at retirement: '//money(res%median_at_retirement)// &
         '   median at age '//i2s(nint(res%ages(res%n_years)))//': '//money(res%median_end)
      print '(a)', ''
   end subroutine print_report

   function rpad(s) result(out)
      character(*), intent(in) :: s
      character(14) :: out

      out = adjustr(s(1:min(len(s), 14)))
      if (len(s) <= 14) then
         out = repeat(' ', 14 - len(s))//s
      end if
   end function rpad

   subroutine write_csv(path, res, ok)
      character(*), intent(in) :: path
      type(sim_result), intent(in) :: res
      logical, intent(out) :: ok
      integer :: u, ios, y

      ok = .false.
      open (newunit=u, file=path, status='replace', action='write', iostat=ios)
      if (ios /= 0) return
      write (u, '(a)') 'age,p05,p25,p50,p75,p95'
      do y = 0, res%n_years
         write (u, '(i0,5(",",f0.2))') nint(res%ages(y)), res%p05(y), &
            res%p25(y), res%p50(y), res%p75(y), res%p95(y)
      end do
      close (u)
      ok = .true.
   end subroutine write_csv

end module fortuna_report
