#Requires AutoHotkey v2.0

; --- Configuration ---
from := "royitaqi@gmail.com"
to := "royitaqi@gmail.com"
subject := "AHK v2 Email Test"
body := "Hello from AutoHotkey v2!"
server := "smtp.gmail.com"
port := 465 ; Port for SSL/TLS
user := "royitaqi@gmail.com"
pwd := "begood@2014" ; Use an App Password, not your main password!

; --- Function to Send Email ---
sendEmail(from, to, subj, body, server, port, user, pwd) {
    pmsg := ComObject("CDO.Message")
    pmsg.From := from
    pmsg.To := to
    pmsg.Subject := subj
    pmsg.TextBody := body

    fields := Object()
    fields.smtpserver := server
    fields.smtpserverport := port
    fields.smtpusessl := True
    fields.sendusing := 2 ; cdoSendUsingPort
    fields.smtpauthenticate := 1 ; cdoBasic
    fields.sendusername := user
    fields.sendpassword := pwd
    fields.smtpconnectiontimeout := 10000 ; default = 60

    log := ""

    For field, value in fields.OwnProps() {
        name := "http://schemas.microsoft.com/cdo/configuration/" field
        pmsg.Configuration.Fields[name] := value

        log .= name " = " value "`n"
    }
    pmsg.Configuration.Fields.Update()

    Try {
        pmsg.Send()
        MsgBox("Email sent successfully!`n`n" log, "Success", 64)
    } Catch as err {
        MsgBox("Error sending email:`n" err.Message "`n`n" log, "Error", 16)
    }
}

; --- Trigger the Email ---
sendEmail(from, to, subject, body, server, port, user, pwd)
