! SPDX-License-Identifier: AGPL-3.0-or-later
! fortuna_json -- a minimal JSON *writer*. Fortuna only ever emits JSON
! (input arrives urlencoded), so no parser is needed.
module fortuna_json
   use fortuna_kinds, only: dp
   implicit none
   private
   public :: jr, jr4, json_real_array, json_escape

contains

   !> Real to JSON number, two decimals (money-ish quantities).
   function jr(x) result(s)
      real(dp), intent(in) :: x
      character(:), allocatable :: s

      s = fmt_fixed(x, 2)
   end function jr

   !> Real to JSON number, four decimals (rates, probabilities).
   function jr4(x) result(s)
      real(dp), intent(in) :: x
      character(:), allocatable :: s

      s = fmt_fixed(x, 4)
   end function jr4

   function fmt_fixed(x, nd) result(s)
      real(dp), intent(in) :: x
      integer, intent(in) :: nd
      character(:), allocatable :: s
      character(48) :: buf
      character(16) :: fmt

      write (fmt, '(a,i0,a)') '(f0.', nd, ')'
      write (buf, fmt) x
      s = trim(adjustl(buf))
      if (len(s) > 0) then
         if (s(1:1) == '.') s = '0'//s
      end if
      if (len(s) > 1) then
         if (s(1:2) == '-.') s = '-0'//s(2:)
      end if
   end function fmt_fixed

   !> Array of reals -> "[a,b,c]" with two decimals.
   function json_real_array(v) result(s)
      real(dp), intent(in) :: v(:)
      character(:), allocatable :: s
      integer :: i

      s = '['
      do i = 1, size(v)
         if (i > 1) s = s//','
         s = s//jr(v(i))
      end do
      s = s//']'
   end function json_real_array

   !> Escape a string for inclusion inside a JSON string literal.
   function json_escape(s) result(out)
      character(*), intent(in) :: s
      character(:), allocatable :: out
      integer :: i, c

      out = ''
      do i = 1, len(s)
         c = iachar(s(i:i))
         select case (s(i:i))
         case ('"')
            out = out//'\"'
         case ('\')
            out = out//'\\'
         case default
            if (c < 32) then
               out = out//' '
            else
               out = out//s(i:i)
            end if
         end select
      end do
   end function json_escape

end module fortuna_json
