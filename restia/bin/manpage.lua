--- Renders a manpage for restia
-- @module restia.bin.manpage
-- @author DarkWiiPlayer
-- @license Unlicense

local restia = require 'restia'
local cosmo = require 'cosmo'

local manpage = cosmo.f [===[
.TH restia 1 "" ""  "Restia web framework"

.SH NAME
.\" ####

\fBrestia\fR - commandline utility for the restia framework

.SH SYNOPSIS
.\" ########

\fBrestia\fR \fBnew\fR [\fIdirectory\fR]
.br
\fBrestia\fR \fBtest\fR [\fIlua\fR [\fIconfiguration\fR]]
.br
\fBrestia\fR \fBrun\fR [\fIconfiguration\fR]
.br
\fBrestia\fR \fBreload\fR [\fIconfiguration\fR]
.br
\fBrestia\fR \fBmanpage\fR [\fIdirectory\fR]
.br
\fBrestia\fR \fBhelp\fR

.SH DESCRIPTION
.\" ###########

Commandline utility for the restia framework

.SH COMMANDS
.\" ########

\fBnew\fR [\fIdirectory\fR]
.br
Creates a new project in the directory \fIdirectory\fR
The default directory is \fBapplication\fR.

\fBtest\fR [\fIlua\fR [\fIconfiguration\fR]]
.br
Runs a list of tests on the web application in the current directory.

\fBrun\fR [\fIconfiguration\fR]
.br
Runs a restia application in the current directory.

\fBreload\fR [\fIconfiguration\fR]
.br
Reloads an already running restia application.

The default \fIconfiguration\fR for the three commands above is \fBopenresty.conf\fR

\fBrestia\fR \fBmanpage\fR [\fIdirectory\fR]
.br
Installs restias manpage in \fIdirectory\fR.
.br
The default directory is \fB/usr/local/man\fR when executed as root and \fB~/.local/share/man\fR otherwise.

\fBhelp\fR
.br
Displays help for the different commands and exit.

\fBrestia\fR

.SH AUTHORS
.\" #######

$contributors[[$name <$email>]]

.SH SEE ALSO
.\" ########

\fBnginx\fR(1)
]===] (restia)

return manpage
