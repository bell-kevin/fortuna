! SPDX-License-Identifier: AGPL-3.0-or-later
! fortuna_forms -- tiny application/x-www-form-urlencoded parser plus a few
! string helpers. No external dependencies; enough to serve the web UI.
module fortuna_forms
   use fortuna_kinds, only: dp
   implicit none
   private
   public :: url_decode, form_get_str, form_get_real, form_get_int, &
             lower, i2s

contains

   !> Decode %XX escapes and '+' -> space.
   function url_decode(s) result(out)
      character(*), intent(in) :: s
      character(:), allocatable :: out
      integer :: i, n, code, ios

      out = ''
      n = len(s)
      i = 1
      do while (i <= n)
         select case (s(i:i))
         case ('+')
            out = out//' '
            i = i + 1
         case ('%')
            if (i + 2 <= n) then
               read (s(i + 1:i + 2), '(z2)', iostat=ios) code
               if (ios == 0 .and. code >= 0 .and. code <= 255) then
                  out = out//achar(code)
               end if
               i = i + 3
            else
               i = n + 1
            end if
         case default
            out = out//s(i:i)
            i = i + 1
         end select
      end do
   end function url_decode

   !> Value for `key` in a body like "a=1&b=hello%20there". found=.false. and
   !> an empty string when the key is absent.
   function form_get_str(body, key, found) result(val)
      character(*), intent(in) :: body, key
      logical, intent(out) :: found
      character(:), allocatable :: val
      integer :: pos, amp, eq, n
      character(:), allocatable :: tok, k

      val = ''
      found = .false.
      n = len_trim(body)
      pos = 1
      do while (pos <= n)
         amp = index(body(pos:n), '&')
         if (amp == 0) then
            tok = body(pos:n)
            pos = n + 1
         else
            tok = body(pos:pos + amp - 2)
            pos = pos + amp
         end if
         eq = index(tok, '=')
         if (eq > 0) then
            k = url_decode(tok(1:eq - 1))
            if (k == key) then
               val = url_decode(tok(eq + 1:))
               found = .true.
               return
            end if
         end if
      end do
   end function form_get_str

   !> Numeric form value with a default. Percent signs are tolerated.
   function form_get_real(body, key, default) result(x)
      character(*), intent(in) :: body, key
      real(dp), intent(in) :: default
      real(dp) :: x
      character(:), allocatable :: v
      logical :: found
      integer :: ios, pc

      x = default
      v = form_get_str(body, key, found)
      if (.not. found) return
      pc = index(v, '%')
      if (pc > 0) v = v(1:pc - 1)
      if (len_trim(v) == 0) return
      read (v, *, iostat=ios) x
      if (ios /= 0) x = default
   end function form_get_real

   function form_get_int(body, key, default) result(k)
      character(*), intent(in) :: body, key
      integer, intent(in) :: default
      integer :: k
      real(dp) :: x

      x = form_get_real(body, key, real(default, dp))
      k = nint(x)
   end function form_get_int

   pure function lower(s) result(out)
      character(*), intent(in) :: s
      character(len(s)) :: out
      integer :: i, c

      do i = 1, len(s)
         c = iachar(s(i:i))
         if (c >= iachar('A') .and. c <= iachar('Z')) then
            out(i:i) = achar(c + 32)
         else
            out(i:i) = s(i:i)
         end if
      end do
   end function lower

   pure function i2s(k) result(s)
      integer, intent(in) :: k
      character(:), allocatable :: s
      character(32) :: buf

      write (buf, '(i0)') k
      s = trim(buf)
   end function i2s

end module fortuna_forms
