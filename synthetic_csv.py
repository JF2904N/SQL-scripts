import csv  #csv module for reading and writing CSV files.

import random  #random module for generating random data.

import string  #string module for working with string constants.

import configparser  # configparser module for parsing INI configuration files.

from faker import Faker  # Faker module for generating synthetic data.

import uuid  # uuid module for generating universally unique identifiers.

import hashlib  # hashlib module for cryptographic hash functions.

import os  # os module for file path operations.

import secrets  # secrets module for generating cryptographically strong random numbers.


def read_config(filename="C:\\DataGenerator\\config\\customerData.cfg"):
    # a function read_config that reads configuration data from a specified file.
    config = configparser.ConfigParser()  #ConfigParser object.
    config.read(filename)  # Read the configuration data from the specified file.
    return config["customer_data"]  # Return the configuration data for the "customer_data" section.
    
def generate_synthetic_data_batch(num_records, config, batch_size=1000):
    for _ in range(0, num_records, batch_size):
        yield generate_synthetic_data(min(batch_size, num_records), config)

def generate_synthetic_data(num_records, config): #FUNCTION to generate synthetic data 
    fake = Faker() #create an instance of faker for generating fake data
    data = []
    used_uids = set() #empty set to keep track of used identifiers
    used_guids = set() #empty set to keep track of used GUIDs
    used_emails = set() #set used emails
    used_sin_numbers = set() #used sin num
    
    for _ in range(num_records):
        guid = str(uuid.uuid4()) #creates unique (GUID)
        salt = secrets.token_hex(8)  #8-byte salt 
        first_name = fake.first_name() 
        last_name = fake.last_name()
        birth_date = fake.date_of_birth(minimum_age=5, maximum_age=100)
        name_and_birthdate = (first_name, last_name, birth_date)   #create a tuple of name and birthdate 
        email_domain = random.choice(eval(config["domains"])) #select random email domain from configuration
        email = f"{first_name.lower()}.{last_name.lower()}{random.randint(1,50)}@{email_domain}"
        hash_key = hashlib.sha256(uuid.uuid4().hex.encode()).hexdigest() # Generate hash key using UUID and SHA-256 hash
        sin_like_number = f"{random.randint(100, 999)}-{random.randint(100, 999)}-{random.randint(100, 999)}"
        unique_identifier = hashlib.sha256((first_name + last_name + sin_like_number + salt).encode()).hexdigest()
        
        # Ensure uniqueness of UID
        while unique_identifier in used_uids:
            unique_identifier = hashlib.sha256((first_name + last_name + sin_like_number + salt).encode()).hexdigest()
        used_uids.add(unique_identifier)
        
        # Ensure uniqueness of GUID
        while guid in used_guids:
            guid = str(uuid.uuid4()) #regenerate guid if it is already used 
        used_guids.add(guid)

        #sin_like_number = None # Initialize SIN-like number variable
        # Ensure uniqueness of SIN-like numbers
        while sin_like_number in used_sin_numbers:
            sin_like_number = f"{random.randint(100, 999)}-{random.randint(100, 999)}-{random.randint(100, 999)}"
        used_sin_numbers.add(sin_like_number)

        # Ensure uniqueness of email
        while email in used_emails:
            email = f"{first_name.lower()}.{last_name.lower()}{random.randint(1,50)}@{email_domain}"
        used_emails.add(email)

        data.append({
            "UID": unique_identifier,
            "GUID": guid,
            "FIRST_NAME": first_name,
            "LAST_NAME": last_name,
            "EMAIL": email,
            "BIRTH_DATE": birth_date,
            "SIN": sin_like_number,
            "SALT": salt,
            "HASHKEY": hash_key,
        })

    print(f"Generated {len(data)} records.")
    return data


def save_to_csv(data, output_filename="synthetic_data.csv"):
    # function save_to_csv that saves data to a CSV file.
    try:
        with open(output_filename, 'w', newline='', encoding='utf-8') as csvfile:
            # Open the CSV file for writing with specified parameters.
            fieldnames = ["UID", "GUID", "FIRST_NAME", "LAST_NAME", "EMAIL", "BIRTH_DATE", "SIN", "SALT", "HASHKEY"]
            # Define the fieldnames for the CSV file.
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)  # Create a DictWriter object with specified fieldnames.
            writer.writeheader()  # header row to the CSV file.
            writer.writerows(data)  # Write all rows of data to the CSV file.
            print("Data inserted successfully into csv table.")
    except Exception as e:
        print(f"An error occurred: {str(e)}")


if __name__ == "__main__":
    num_records = int(input("Enter the number of synthetic records to generate: "))
    config = read_config()

    batches = generate_synthetic_data_batch(num_records, config, batch_size=1000)
    data = []
    for batch in batches:
        data.extend(batch)
        if len(data) >= num_records:
            break

    save_to_csv(data)


