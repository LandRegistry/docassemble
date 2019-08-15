import os
from docassemble.webapp.db_object import db

def executeScriptsFromFile(filename):
    # Open and read the file as a single buffer
    fd = open(filename, 'r')
    sqlFile = fd.read()
    fd.close()

    # all SQL commands (split on ';')
    sqlCommands = sqlFile.split(';')

    # Execute every command from the input file
    for command in sqlCommands:
        # This will skip and report errors
        try:
            db.session.execute(command)
            db.session.commit()
        except Exception as ex:
            print("Command skipped: Command = %s, Error = %s" % (command, str(ex)))

def completeInstall():
    for file in os.listdir("/SQL"):
        if file.endswith(".sql"):
            executeScriptsFromFile(file)