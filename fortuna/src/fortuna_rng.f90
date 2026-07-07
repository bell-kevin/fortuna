! SPDX-License-Identifier: AGPL-3.0-or-later
! fortuna_rng -- seeding helpers and a Box-Muller Gaussian sampler on top of
! the intrinsic uniform generator.
module fortuna_rng
   use fortuna_kinds, only: dp
   implicit none
   private
   public :: rng_init, rand_normal

   logical  :: have_spare = .false.
   real(dp) :: spare = 0.0_dp

contains

   !> Initialise the intrinsic RNG. seed > 0 gives a reproducible stream;
   !> seed <= 0 seeds from the system (non-reproducible).
   subroutine rng_init(seed)
      integer, intent(in) :: seed
      integer :: n, i
      integer, allocatable :: s(:)

      call random_seed(size=n)
      allocate (s(n))
      if (seed > 0) then
         do i = 1, n
            s(i) = seed + 104729*i + 7919*i*i   ! spread across the state
         end do
         call random_seed(put=s)
      else
         call random_seed()
      end if
      have_spare = .false.
      spare = 0.0_dp
   end subroutine rng_init

   !> Standard normal deviate via the Box-Muller transform (with caching).
   function rand_normal() result(z)
      real(dp) :: z
      real(dp) :: u1, u2, r, t
      real(dp), parameter :: two_pi = 2.0_dp*acos(-1.0_dp)

      if (have_spare) then
         z = spare
         have_spare = .false.
         return
      end if
      do
         call random_number(u1)
         if (u1 > 0.0_dp) exit
      end do
      call random_number(u2)
      r = sqrt(-2.0_dp*log(u1))
      t = two_pi*u2
      z = r*cos(t)
      spare = r*sin(t)
      have_spare = .true.
   end function rand_normal

end module fortuna_rng
