! SPDX-License-Identifier: AGPL-3.0-or-later
! fortuna_http -- an HTTP/1.1 server written in Fortran.
!
! No frameworks, no C helper files, no dependencies: the module binds
! directly to libc's socket calls through iso_c_binding. It is a small,
! sequential, connection-per-request server -- exactly enough to power the
! local web UI. Not intended to face the public internet.
module fortuna_http
   use, intrinsic :: iso_c_binding
   use, intrinsic :: iso_fortran_env, only: output_unit
   use fortuna_kinds, only: dp
   use fortuna_sim, only: sim_config, sim_result, run_simulation, &
                          solve_safe_spend, validate_config
   use fortuna_forms, only: form_get_real, form_get_int, form_get_str, &
                            lower, i2s
   use fortuna_json, only: jr, jr4, json_real_array, json_escape
   use fortuna_web_assets, only: index_html
   implicit none
   private
   public :: http_serve

   ! --- libc constants (Linux) -------------------------------------------
   integer(c_int), parameter :: AF_INET = 2
   integer(c_int), parameter :: SOCK_STREAM = 1
   integer(c_int), parameter :: SOL_SOCKET = 1
   integer(c_int), parameter :: SO_REUSEADDR = 2
   integer(c_int), parameter :: SO_RCVTIMEO = 20
   integer(c_int), parameter :: MSG_NOSIGNAL = 16384

   character(2), parameter :: crlf = char(13)//char(10)
   integer, parameter :: max_request = 1048576   ! 1 MiB cap

   type, bind(c) :: sockaddr_in
      integer(c_int16_t) :: sin_family = 0_c_int16_t
      integer(c_int16_t) :: sin_port = 0_c_int16_t
      integer(c_int32_t) :: sin_addr = 0_c_int32_t
      integer(c_int8_t)  :: sin_zero(8) = 0_c_int8_t
   end type sockaddr_in

   type, bind(c) :: c_timeval
      integer(c_long) :: tv_sec = 0_c_long
      integer(c_long) :: tv_usec = 0_c_long
   end type c_timeval

   interface
      function c_socket(domain, styp, protocol) bind(c, name='socket') result(fd)
         import :: c_int
         integer(c_int), value :: domain, styp, protocol
         integer(c_int) :: fd
      end function c_socket

      function c_setsockopt(fd, level, optname, optval, optlen) &
         bind(c, name='setsockopt') result(rc)
         import :: c_int, c_ptr
         integer(c_int), value :: fd, level, optname
         type(c_ptr), value :: optval
         integer(c_int), value :: optlen
         integer(c_int) :: rc
      end function c_setsockopt

      function c_bind(fd, addr, addrlen) bind(c, name='bind') result(rc)
         import :: c_int, c_ptr
         integer(c_int), value :: fd
         type(c_ptr), value :: addr
         integer(c_int), value :: addrlen
         integer(c_int) :: rc
      end function c_bind

      function c_listen(fd, backlog) bind(c, name='listen') result(rc)
         import :: c_int
         integer(c_int), value :: fd, backlog
         integer(c_int) :: rc
      end function c_listen

      function c_accept(fd, addr, addrlen) bind(c, name='accept') result(cfd)
         import :: c_int, c_ptr
         integer(c_int), value :: fd
         type(c_ptr), value :: addr, addrlen
         integer(c_int) :: cfd
      end function c_accept

      function c_recv(fd, buf, n, flags) bind(c, name='recv') result(r)
         import :: c_int, c_ptr, c_size_t, c_ptrdiff_t
         integer(c_int), value :: fd
         type(c_ptr), value :: buf
         integer(c_size_t), value :: n
         integer(c_int), value :: flags
         integer(c_ptrdiff_t) :: r
      end function c_recv

      function c_send(fd, buf, n, flags) bind(c, name='send') result(r)
         import :: c_int, c_ptr, c_size_t, c_ptrdiff_t
         integer(c_int), value :: fd
         type(c_ptr), value :: buf
         integer(c_size_t), value :: n
         integer(c_int), value :: flags
         integer(c_ptrdiff_t) :: r
      end function c_send

      function c_close(fd) bind(c, name='close') result(rc)
         import :: c_int
         integer(c_int), value :: fd
         integer(c_int) :: rc
      end function c_close

      function c_inet_addr(cp) bind(c, name='inet_addr') result(addr)
         import :: c_char, c_int32_t
         character(kind=c_char), dimension(*), intent(in) :: cp
         integer(c_int32_t) :: addr
      end function c_inet_addr
   end interface

contains

   ! ======================================================================
   ! Server loop
   ! ======================================================================

   subroutine http_serve(host, port, defaults, webroot)
      character(*), intent(in) :: host
      integer, intent(in) :: port
      type(sim_config), intent(in) :: defaults
      character(*), intent(in) :: webroot   ! '' -> serve the embedded UI

      integer(c_int) :: sfd, cfd, rc
      integer(c_int), target :: one
      type(sockaddr_in), target :: addr
      type(c_timeval), target :: tv

      sfd = c_socket(AF_INET, SOCK_STREAM, 0_c_int)
      if (sfd < 0) then
         print '(a)', 'fortuna: could not create socket'
         stop 1
      end if

      one = 1
      rc = c_setsockopt(sfd, SOL_SOCKET, SO_REUSEADDR, c_loc(one), 4_c_int)

      addr%sin_family = int(AF_INET, c_int16_t)
      addr%sin_port = to_net16(port)
      addr%sin_addr = c_inet_addr(trim(host)//c_null_char)

      rc = c_bind(sfd, c_loc(addr), int(storage_size(addr)/8, c_int))
      if (rc /= 0) then
         print '(a)', 'fortuna: could not bind to '//trim(host)//':'//i2s(port)// &
            ' (port in use, or host invalid?)'
         stop 1
      end if
      rc = c_listen(sfd, 16_c_int)
      if (rc /= 0) then
         print '(a)', 'fortuna: listen() failed'
         stop 1
      end if

      print '(a)', ''
      print '(a)', '  fortuna is serving its web UI (100% Fortran backend)'
      print '(a)', '  open:  http://'//trim(host)//':'//i2s(port)//'/'
      print '(a)', '  stop:  Ctrl+C'
      print '(a)', ''
      flush (output_unit)

      do
         cfd = c_accept(sfd, c_null_ptr, c_null_ptr)
         if (cfd < 0) cycle
         tv%tv_sec = 5_c_long
         tv%tv_usec = 0_c_long
         rc = c_setsockopt(cfd, SOL_SOCKET, SO_RCVTIMEO, c_loc(tv), &
                           int(storage_size(tv)/8, c_int))
         call handle_client(cfd, defaults, webroot)
         rc = c_close(cfd)
      end do
   end subroutine http_serve

   ! ======================================================================
   ! Per-connection handling
   ! ======================================================================

   subroutine handle_client(cfd, defaults, webroot)
      integer(c_int), intent(in) :: cfd
      type(sim_config), intent(in) :: defaults
      character(*), intent(in) :: webroot

      character(:), allocatable :: req, method, path, query, body
      character(:), allocatable :: params, payload, page, err
      integer :: status
      logical :: ok

      call read_request(cfd, req, ok)
      if (.not. ok) return
      call parse_request(req, method, path, query, body)

      status = 200
      if (path == '/' .or. path == '/index.html') then
         if (method /= 'GET' .and. method /= 'HEAD') then
            status = 405
            payload = 'method not allowed'
            call sock_send_all(cfd, http_response(status, 'text/plain; charset=utf-8', payload))
         else
            page = load_page(webroot)
            call sock_send_all(cfd, http_response(200, 'text/html; charset=utf-8', page))
         end if
      else if (path == '/api/simulate') then
         params = trim(query)//'&'//trim(body)
         payload = api_simulate(params, defaults, err)
         if (len(err) > 0) then
            status = 400
            payload = '{"error":"'//json_escape(err)//'"}'
         end if
         call sock_send_all(cfd, http_response(status, 'application/json', payload))
      else if (path == '/api/health') then
         call sock_send_all(cfd, http_response(200, 'application/json', '{"ok":true}'))
      else if (path == '/favicon.ico') then
         status = 204
         call sock_send_all(cfd, http_response(204, 'text/plain', ''))
      else
         status = 404
         call sock_send_all(cfd, http_response(404, 'text/plain; charset=utf-8', 'not found'))
      end if

      print '(a)', '  '//method//' '//path//' -> '//i2s(status)
      flush (output_unit)
   end subroutine handle_client

   !> Serve web/index.html from `webroot` when given (developer mode);
   !> otherwise the page compiled into the binary.
   function load_page(webroot) result(page)
      character(*), intent(in) :: webroot
      character(:), allocatable :: page
      integer :: u, ios, sz

      if (len_trim(webroot) > 0) then
         open (newunit=u, file=trim(webroot)//'/index.html', access='stream', &
               form='unformatted', status='old', action='read', iostat=ios)
         if (ios == 0) then
            inquire (unit=u, size=sz)
            if (sz > 0) then
               allocate (character(sz) :: page)
               read (u, iostat=ios) page
               close (u)
               if (ios == 0) return
               deallocate (page)
            else
               close (u)
            end if
         end if
      end if
      page = index_html()
   end function load_page

   ! ======================================================================
   ! The /api/simulate endpoint
   ! ======================================================================

   function api_simulate(params, defaults, err) result(payload)
      character(*), intent(in) :: params
      type(sim_config), intent(in) :: defaults
      character(:), allocatable, intent(out) :: err
      character(:), allocatable :: payload

      type(sim_config) :: cfg
      type(sim_result) :: res
      real(dp) :: target, solved, achieved
      integer :: solve
      character(:), allocatable :: solved_json

      err = ''
      payload = ''
      cfg = defaults
      cfg%current_age = form_get_real(params, 'age', cfg%current_age)
      cfg%retire_age = form_get_real(params, 'retire', cfg%retire_age)
      cfg%end_age = form_get_real(params, 'end', cfg%end_age)
      cfg%balance0 = form_get_real(params, 'balance', cfg%balance0)
      cfg%monthly_contrib = form_get_real(params, 'monthly', cfg%monthly_contrib)
      cfg%contrib_growth = form_get_real(params, 'growth', cfg%contrib_growth*100.0_dp)/100.0_dp
      cfg%annual_return = form_get_real(params, 'return', cfg%annual_return*100.0_dp)/100.0_dp
      cfg%annual_vol = form_get_real(params, 'vol', cfg%annual_vol*100.0_dp)/100.0_dp
      cfg%annual_spend = form_get_real(params, 'spend', cfg%annual_spend)
      cfg%pension_monthly = form_get_real(params, 'pension', cfg%pension_monthly)
      cfg%pension_age = form_get_real(params, 'pension_age', cfg%pension_age)
      cfg%n_paths = form_get_int(params, 'paths', cfg%n_paths)
      cfg%seed = form_get_int(params, 'seed', cfg%seed)
      solve = form_get_int(params, 'solve', 0)
      target = form_get_real(params, 'target', 90.0_dp)/100.0_dp
      target = min(max(target, 0.5_dp), 0.999_dp)

      err = validate_config(cfg)
      if (len(err) > 0) return

      solved_json = ''
      if (solve == 1) then
         call solve_safe_spend(cfg, target, solved, achieved)
         cfg%annual_spend = solved
         solved_json = ',"solved_spend":'//jr(solved)// &
                       ',"solved_target":'//jr4(target)// &
                       ',"solved_achieved":'//jr4(achieved)
      end if

      call run_simulation(cfg, res)

      payload = '{"success_rate":'//jr4(res%success_rate)// &
                ',"ages":'//json_real_array(res%ages)// &
                ',"p05":'//json_real_array(res%p05)// &
                ',"p25":'//json_real_array(res%p25)// &
                ',"p50":'//json_real_array(res%p50)// &
                ',"p75":'//json_real_array(res%p75)// &
                ',"p95":'//json_real_array(res%p95)// &
                ',"median_end":'//jr(res%median_end)// &
                ',"mean_end":'//jr(res%mean_end)// &
                ',"median_at_retirement":'//jr(res%median_at_retirement)// &
                ',"retire_age":'//jr(cfg%retire_age)// &
                ',"annual_spend":'//jr(cfg%annual_spend)// &
                ',"paths":'//i2s(cfg%n_paths)// &
                solved_json//'}'
   end function api_simulate

   ! ======================================================================
   ! HTTP plumbing
   ! ======================================================================

   subroutine read_request(cfd, req, ok)
      integer(c_int), intent(in) :: cfd
      character(:), allocatable, intent(out) :: req
      logical, intent(out) :: ok

      character(kind=c_char), target :: chunk(4096)
      character(:), allocatable :: hdr_low
      integer :: n, hdr_end, clen, needed, p, ios

      req = ''
      ok = .false.
      clen = -1
      needed = -1
      do
         n = sock_recv(cfd, chunk)
         if (n <= 0) return
         req = req//chunk_to_string(chunk, n)
         if (len(req) > max_request) return

         hdr_end = index(req, crlf//crlf)
         if (hdr_end == 0) cycle

         if (needed < 0) then
            hdr_low = lower(req(1:hdr_end - 1))
            p = index(hdr_low, 'content-length:')
            if (p > 0) then
               read (hdr_low(p + 15:), *, iostat=ios) clen
               if (ios /= 0) clen = 0
            else
               clen = 0
            end if
            clen = min(max(clen, 0), max_request)
            needed = hdr_end + 3 + clen
         end if
         if (len(req) >= needed) exit
      end do
      ok = .true.
   end subroutine read_request

   subroutine parse_request(req, method, path, query, body)
      character(*), intent(in) :: req
      character(:), allocatable, intent(out) :: method, path, query, body

      character(:), allocatable :: line, target_str
      integer :: eol, sp1, sp2, hdr_end, q

      method = ''
      path = '/'
      query = ''
      body = ''

      eol = index(req, crlf)
      if (eol == 0) return
      line = req(1:eol - 1)

      sp1 = index(line, ' ')
      if (sp1 == 0) return
      method = line(1:sp1 - 1)
      sp2 = index(line(sp1 + 1:), ' ')
      if (sp2 == 0) then
         target_str = line(sp1 + 1:)
      else
         target_str = line(sp1 + 1:sp1 + sp2 - 1)
      end if

      q = index(target_str, '?')
      if (q > 0) then
         path = target_str(1:q - 1)
         query = target_str(q + 1:)
      else
         path = target_str
      end if
      if (len(path) == 0) path = '/'

      hdr_end = index(req, crlf//crlf)
      if (hdr_end > 0 .and. hdr_end + 4 <= len(req)) body = req(hdr_end + 4:)
   end subroutine parse_request

   function http_response(status, ctype, body) result(r)
      integer, intent(in) :: status
      character(*), intent(in) :: ctype, body
      character(:), allocatable :: r, stext

      select case (status)
      case (200); stext = 'OK'
      case (204); stext = 'No Content'
      case (400); stext = 'Bad Request'
      case (404); stext = 'Not Found'
      case (405); stext = 'Method Not Allowed'
      case default; stext = 'Internal Server Error'
      end select

      r = 'HTTP/1.1 '//i2s(status)//' '//stext//crlf// &
          'Server: fortuna (Fortran)'//crlf// &
          'Content-Type: '//ctype//crlf// &
          'Content-Length: '//i2s(len(body))//crlf// &
          'Cache-Control: no-store'//crlf// &
          'Connection: close'//crlf//crlf//body
   end function http_response

   ! ======================================================================
   ! Socket helpers
   ! ======================================================================

   function sock_recv(fd, buf) result(n)
      integer(c_int), intent(in) :: fd
      character(kind=c_char), intent(inout), target :: buf(:)
      integer :: n
      integer(c_ptrdiff_t) :: rc

      rc = c_recv(fd, c_loc(buf), int(size(buf), c_size_t), 0_c_int)
      n = int(rc)
   end function sock_recv

   subroutine sock_send_all(fd, dat)
      integer(c_int), intent(in) :: fd
      character(*), intent(in) :: dat

      character(kind=c_char), allocatable, target :: buf(:)
      integer(c_ptrdiff_t) :: rc
      integer :: i, n, sent

      n = len(dat)
      if (n == 0) n = 0
      allocate (buf(max(n, 1)))
      do i = 1, n
         buf(i) = dat(i:i)
      end do
      sent = 0
      do while (sent < n)
         rc = c_send(fd, c_loc(buf(sent + 1)), int(n - sent, c_size_t), MSG_NOSIGNAL)
         if (rc <= 0) exit
         sent = sent + int(rc)
      end do
   end subroutine sock_send_all

   function chunk_to_string(chunk, n) result(s)
      character(kind=c_char), intent(in) :: chunk(:)
      integer, intent(in) :: n
      character(:), allocatable :: s
      integer :: i

      allocate (character(n) :: s)
      do i = 1, n
         s(i:i) = achar(iachar(chunk(i)))
      end do
   end function chunk_to_string

   !> Port number -> 16-bit value in network byte order, endian-independent:
   !> build the two bytes explicitly and reinterpret them in memory order.
   pure function to_net16(port) result(nport)
      integer, intent(in) :: port
      integer(c_int16_t) :: nport
      integer(c_int8_t) :: b(2)

      b(1) = to_s8(iand(ishft(port, -8), 255))   ! high byte first
      b(2) = to_s8(iand(port, 255))
      nport = transfer(b, nport)
   end function to_net16

   pure function to_s8(v) result(r)
      integer, intent(in) :: v
      integer(c_int8_t) :: r

      if (v > 127) then
         r = int(v - 256, c_int8_t)
      else
         r = int(v, c_int8_t)
      end if
   end function to_s8

end module fortuna_http
