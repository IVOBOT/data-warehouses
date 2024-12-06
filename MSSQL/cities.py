from faker import Faker
import pandas as pd
import uuid
from datetime import date, datetime, timedelta
import random
import numpy as np

fake = Faker()
cities = []
city_number = 100
for i in range(city_number):
    cities.append(fake.city())

print(cities)