! SPDX-License-Identifier: AGPL-3.0-or-later
!
! fortuna -- a Monte Carlo personal-finance forecaster, full-stack Fortran.
! Copyright (C) 2026  fortuna contributors
!
! This program is free software: you can redistribute it and/or modify it
! under the terms of the GNU Affero General Public License as published by
! the Free Software Foundation, either version 3 of the License, or (at
! your option) any later version.
!
! This program is distributed in the hope that it will be useful, but
! WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero
! General Public License for more details:
! <https://www.gnu.org/licenses/agpl-3.0.html>.
program fortuna
   use fortuna_cli, only: run_cli
   implicit none

   call run_cli()
end program fortuna
