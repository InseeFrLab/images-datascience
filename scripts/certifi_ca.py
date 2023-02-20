import certifi
import os

##
# This script override certifi certificates that allow most python package
# to query https enpoint with custom certificates
##
print("certifi add certificates")
cafile = certifi.where()
with open(os.environ['PATH_TO_CA_BUNDLE'], 'rb') as infile:
    customca = infile.read()
with open(cafile, 'ab') as outfile:
    print("writing to "+str(cafile))
    outfile.write(customca)