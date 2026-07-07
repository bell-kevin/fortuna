! SPDX-License-Identifier: AGPL-3.0-or-later
! fortuna_sim -- the Monte Carlo engine.
!
! Model, in brief:
!   * Everything is expressed in TODAY'S dollars (real terms). "Return" and
!     "volatility" are therefore real (inflation-adjusted) figures.
!   * Monthly log-returns are i.i.d. normal with
!       mu_m    = ln(1 + R)/12 - sigma_m**2/2
!       sigma_m = sigma/sqrt(12)
!     so that the expected annual growth factor is exactly (1 + R).
!   * Accumulation phase (age < retire_age): monthly contribution, growing
!     by contrib_growth per year in real terms.
!   * Retirement phase (age >= retire_age): withdraw annual_spend/12 each
!     month; pension_monthly income begins at pension_age.
!   * A path "fails" if the balance is ever depleted during retirement.
module fortuna_sim
   use fortuna_kinds, only: dp
   use fortuna_rng, only: rng_init, rand_normal
   implicit none
   private
   public :: sim_config, sim_result, run_simulation, solve_safe_spend, &
             validate_config, percentile

   type :: sim_config
      real(dp) :: current_age = 30.0_dp
      real(dp) :: retire_age = 65.0_dp
      real(dp) :: end_age = 95.0_dp
      real(dp) :: balance0 = 25000.0_dp
      real(dp) :: monthly_contrib = 500.0_dp
      real(dp) :: contrib_growth = 0.01_dp   ! real growth of contributions /yr
      real(dp) :: annual_return = 0.05_dp    ! real expected return /yr
      real(dp) :: annual_vol = 0.15_dp       ! annual volatility
      real(dp) :: annual_spend = 40000.0_dp  ! real spending in retirement /yr
      real(dp) :: pension_monthly = 0.0_dp   ! Social Security / pension /mo
      real(dp) :: pension_age = 67.0_dp
      integer  :: n_paths = 10000
      integer  :: seed = 0                   ! <=0 means random seed
   end type sim_config

   type :: sim_result
      integer :: n_years = 0
      real(dp), allocatable :: ages(:)                       ! (0:n_years)
      real(dp), allocatable :: p05(:), p25(:), p50(:), p75(:), p95(:)
      real(dp) :: success_rate = 0.0_dp
      real(dp) :: median_end = 0.0_dp
      real(dp) :: mean_end = 0.0_dp
      real(dp) :: median_at_retirement = 0.0_dp
   end type sim_result

contains

   !> Basic sanity checks. Returns an empty string when the config is usable.
   function validate_config(cfg) result(err)
      type(sim_config), intent(inout) :: cfg
      character(:), allocatable :: err

      err = ''
      if (cfg%current_age < 0.0_dp .or. cfg%current_age > 120.0_dp) then
         err = 'current age must be between 0 and 120'; return
      end if
      if (cfg%end_age <= cfg%current_age) then
         err = 'plan-until age must be greater than current age'; return
      end if
      if (cfg%end_age > 130.0_dp) then
         err = 'plan-until age must be 130 or less'; return
      end if
      if (cfg%annual_return <= -0.99_dp .or. cfg%annual_return > 1.0_dp) then
         err = 'expected return must be between -99% and 100%'; return
      end if
      if (cfg%annual_vol < 0.0_dp .or. cfg%annual_vol > 2.0_dp) then
         err = 'volatility must be between 0% and 200%'; return
      end if
      if (cfg%annual_spend < 0.0_dp .or. cfg%monthly_contrib < 0.0_dp .or. &
          cfg%balance0 < 0.0_dp .or. cfg%pension_monthly < 0.0_dp) then
         err = 'dollar amounts must not be negative'; return
      end if
      cfg%retire_age = min(max(cfg%retire_age, cfg%current_age), cfg%end_age)
      cfg%n_paths = min(max(cfg%n_paths, 100), 200000)
   end function validate_config

   !> Run the full Monte Carlo and fill a sim_result with yearly percentile
   !> bands and summary statistics.
   subroutine run_simulation(cfg, res)
      type(sim_config), intent(in) :: cfg
      type(sim_result), intent(out) :: res

      integer :: total_years, months, np, p, m, y, year_idx, retire_year, n_fail
      real(dp) :: mu_m, sig_m, bal, age_m, spend_m
      real(dp), allocatable :: snap(:, :)   ! (path, 0:total_years)
      real(dp), allocatable :: col(:)
      logical :: failed

      total_years = max(1, nint(cfg%end_age - cfg%current_age))
      months = total_years*12
      np = cfg%n_paths
      mu_m = log(1.0_dp + cfg%annual_return)/12.0_dp - 0.5_dp*cfg%annual_vol**2/12.0_dp
      sig_m = cfg%annual_vol/sqrt(12.0_dp)
      spend_m = cfg%annual_spend/12.0_dp

      allocate (snap(np, 0:total_years))
      call rng_init(cfg%seed)

      n_fail = 0
      do p = 1, np
         bal = cfg%balance0
         failed = .false.
         snap(p, 0) = bal
         do m = 1, months
            age_m = cfg%current_age + real(m - 1, dp)/12.0_dp
            year_idx = (m - 1)/12
            bal = bal*exp(mu_m + sig_m*rand_normal())
            if (age_m < cfg%retire_age) then
               bal = bal + cfg%monthly_contrib*(1.0_dp + cfg%contrib_growth)**year_idx
            else
               bal = bal - spend_m
            end if
            if (age_m >= cfg%pension_age) bal = bal + cfg%pension_monthly
            if (bal <= 0.0_dp) then
               bal = 0.0_dp
               if (age_m >= cfg%retire_age) failed = .true.
            end if
            if (mod(m, 12) == 0) snap(p, year_idx + 1) = bal
         end do
         if (failed) n_fail = n_fail + 1
      end do

      res%n_years = total_years
      allocate (res%ages(0:total_years), res%p05(0:total_years), &
                res%p25(0:total_years), res%p50(0:total_years), &
                res%p75(0:total_years), res%p95(0:total_years))
      allocate (col(np))
      do y = 0, total_years
         res%ages(y) = cfg%current_age + real(y, dp)
         col = snap(:, y)
         call heapsort(col)
         res%p05(y) = percentile_sorted(col, 0.05_dp)
         res%p25(y) = percentile_sorted(col, 0.25_dp)
         res%p50(y) = percentile_sorted(col, 0.50_dp)
         res%p75(y) = percentile_sorted(col, 0.75_dp)
         res%p95(y) = percentile_sorted(col, 0.95_dp)
      end do

      res%success_rate = 1.0_dp - real(n_fail, dp)/real(np, dp)
      res%median_end = res%p50(total_years)
      res%mean_end = sum(snap(:, total_years))/real(np, dp)
      retire_year = min(max(nint(cfg%retire_age - cfg%current_age), 0), total_years)
      res%median_at_retirement = res%p50(retire_year)
   end subroutine run_simulation

   !> Find the largest annual retirement spend whose success rate is still at
   !> least `target` (e.g. 0.90). Uses a fixed seed internally so the search
   !> is over a deterministic, monotone function; expands then bisects.
   subroutine solve_safe_spend(cfg, target, spend, achieved)
      type(sim_config), intent(in) :: cfg
      real(dp), intent(in) :: target
      real(dp), intent(out) :: spend, achieved

      type(sim_config) :: c
      type(sim_result) :: r
      real(dp) :: lo, hi, mid, s_hi
      integer :: it

      c = cfg
      c%n_paths = min(cfg%n_paths, 4000)
      if (c%seed <= 0) c%seed = 20260707

      lo = 0.0_dp
      hi = max(cfg%annual_spend, 20000.0_dp)
      do it = 1, 24                     ! grow hi until it fails the target
         c%annual_spend = hi
         call run_simulation(c, r)
         s_hi = r%success_rate
         if (s_hi < target .or. hi > 1.0e9_dp) exit
         lo = hi
         hi = hi*2.0_dp
      end do

      do it = 1, 32                     ! bisect
         if (hi - lo < 50.0_dp) exit
         mid = 0.5_dp*(lo + hi)
         c%annual_spend = mid
         call run_simulation(c, r)
         if (r%success_rate >= target) then
            lo = mid
         else
            hi = mid
         end if
      end do

      spend = lo
      c%annual_spend = spend
      call run_simulation(c, r)
      achieved = r%success_rate
   end subroutine solve_safe_spend

   !> Percentile of an unsorted array (sorts a copy).
   function percentile(v, q) result(x)
      real(dp), intent(in) :: v(:)
      real(dp), intent(in) :: q
      real(dp) :: x
      real(dp), allocatable :: w(:)

      w = v
      call heapsort(w)
      x = percentile_sorted(w, q)
   end function percentile

   !> Linear-interpolated percentile of an ascending-sorted array.
   pure function percentile_sorted(v, q) result(x)
      real(dp), intent(in) :: v(:)
      real(dp), intent(in) :: q
      real(dp) :: x, pos, frac
      integer :: n, lo

      n = size(v)
      if (n == 1) then
         x = v(1); return
      end if
      pos = 1.0_dp + q*real(n - 1, dp)
      lo = int(pos)
      if (lo >= n) then
         x = v(n); return
      end if
      frac = pos - real(lo, dp)
      x = v(lo)*(1.0_dp - frac) + v(lo + 1)*frac
   end function percentile_sorted

   !> In-place ascending heapsort.
   pure subroutine heapsort(a)
      real(dp), intent(inout) :: a(:)
      integer :: n, i
      real(dp) :: t

      n = size(a)
      do i = n/2, 1, -1
         call sift_down(a, i, n)
      end do
      do i = n, 2, -1
         t = a(1); a(1) = a(i); a(i) = t
         call sift_down(a, 1, i - 1)
      end do
   end subroutine heapsort

   pure subroutine sift_down(a, start, last)
      real(dp), intent(inout) :: a(:)
      integer, intent(in) :: start, last
      integer :: root, child
      real(dp) :: t

      root = start
      do
         child = 2*root
         if (child > last) exit
         if (child < last) then
            if (a(child + 1) > a(child)) child = child + 1
         end if
         if (a(root) < a(child)) then
            t = a(root); a(root) = a(child); a(child) = t
            root = child
         else
            exit
         end if
      end do
   end subroutine sift_down

end module fortuna_sim
