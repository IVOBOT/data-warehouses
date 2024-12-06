from faker import Faker
import pandas as pd
import uuid
from datetime import date, datetime, timedelta
import random
import numpy as np


def random_starting_position(age, min_age, max_age):
    age_range = max_age - min_age - 20
    normalized_age = age - min_age
    positions_len = len(positions)
    mean_index_of_position = min(normalized_age * positions_len / age_range, positions_len)
    while True:
        position_index = int(np.random.normal(mean_index_of_position, positions_len / 4))
        if 0 <= position_index < positions_len:
            return positions[position_index]


def random_starting_wage(position, min_wage, max_wage):
    wage_range = max_wage - min_wage
    positions_len = len(positions)
    wage_gain_per_position = wage_range / positions_len
    position_index = find_position_index(position)
    while True:
        wage = min_wage + wage_gain_per_position * np.random.normal(position_index, positions_len / 4)
        if min_wage <= wage < max_wage:
            return int(wage)


def get_next_wage(starting, max_raise):
    return int(starting + random.random() * max_raise)


def find_position_index(position):
    for index in range(len(positions)):
        if position == positions[index]:
            return index


def get_next_position(current):
    index = find_position_index(current)
    if index < len(positions) - 1:
        return positions[index + 1]
    return None


def generate_birth_date():
    start_date = datetime(1950, 1, 1)
    end_date = datetime(2000, 12, 31)
    return fake.date_of_birth(minimum_age=20, maximum_age=70).strftime("%Y-%m-%d")


def generate_start_date():
    start_date = datetime(2020, 1, 1)
    return start_date + timedelta(days=random.randint(0, 1460))


def generate_end_date(start_date):
    end_date = start_date + timedelta(days=random.randint(30, 365))
    return end_date.strftime("%Y-%m-%d")


def generate_wage():
    return round(random.uniform(3000, 12000), 2)


def generate_pesel(birth_date):
    day = birth_date.day
    month = birth_date.month
    year = birth_date.year % 100

    gender_digit = random.randint(0, 9)

    pesel = f"{year:02}{month:02}{day:02}{gender_digit}{random.randint(0, 999):03}"

    control_digit = (1 * int(pesel[0]) + 3 * int(pesel[1]) + 7 * int(pesel[2]) +
                     9 * int(pesel[3]) + 1 * int(pesel[4]) + 3 * int(pesel[5]) +
                     7 * int(pesel[6]) + 9 * int(pesel[7]) + 1 * int(pesel[8]) +
                     3 * int(pesel[9])) % 10

    if control_digit != 0:
        control_digit = 10 - control_digit

    pesel += str(control_digit)

    return pesel


def generate_weakly_negatively_correlated(minimal, maximum, factor, noise_level=0.2):
    x = random.uniform(minimal, maximum)
    x = int(x - noise_level * random.random() * factor)
    return max(minimal, x)


def random_department():
    return random.choice(departments)


def calculate_adulthood_date(birthday):
    try:
        return birthday.replace(year=birthday.year + 18)
    except ValueError:
        return birthday.replace(year=birthday.year + 18, day=1, month=3)


def generate_time_interval(unit, max):
    return timedelta(days=random.randint(unit, unit * max))


def find_status_index(current):
    for index in range(len(states_of_claim)):
        if current == states_of_claim[index]:
            return index


def get_next_status_of_claim(current, evaluator_position, evaluator_disputes, claim, threshold):
    current_index = find_status_index(current)
    if current == "received":
        return "pending"
    if current == "pending":
        return "in evaluation"
    if current == "in evaluation":
        return "proposed"
    if evaluator_disputes:
        if current == "proposed":
            dispute_probability = (0.5 * (find_position_index(evaluator_position) + 1) / len(positions)) * (
                    claim - threshold) / threshold
            if random.random() <= dispute_probability:
                return "in dispute"
            else:
                return "resolved"
        if current == "in dispute":
            if random.random() <= 0.5:
                return "resolved"
            else:
                return "proposed"
    else:
        if current == "proposed":
            if random.random() <= (threshold - claim) / threshold:
                return "in dispute"
            else:
                return "resolved"
        if current == "in dispute":
            if random.random() <= 0.5:
                return "resolved"
            else:
                return "proposed"


def random_date(start, end):
    while True:
        try:
            return fake.date_between(start_date=start, end_date=end)
        except:
            a = 1


def generate_employees(employee_number, start_year, middle_year, end_year, min_age, max_age,
                       department_switch_probability):
    for _ in range(employee_number):
        birthday = fake.date_of_birth(minimum_age=min_age, maximum_age=max_age)
        pesel = generate_pesel(birthday)
        last_day = date(end_year, 12, 31)
        first_second_day = date(middle_year, 1, 1)
        adulthood_date = calculate_adulthood_date(birthday)
        start_of_work = max(date(start_year, 1, 1), adulthood_date + timedelta(
            days=random.randint(0, (last_day - adulthood_date).days)))
        position = random_starting_position((start_of_work - birthday).days / 365, min_age, max_age)
        first_name = fake.first_name()
        last_name = fake.last_name()
        wage = random_starting_wage(position, 3000, 20000)
        department = random_department()
        is_in_the_second_period = False
        while True:
            days_at_position = generate_time_interval(365, 10)
            is_last_position = False
            is_in_the_switchup = False
            if start_of_work + days_at_position >= first_second_day:
                if not is_in_the_second_period:
                    is_in_the_switchup = True
                is_in_the_second_period = True
            if start_of_work + days_at_position >= last_day or get_next_position(position) is None:
                is_last_position = True
            if random.random() <= department_switch_probability:
                department = random_department()
            id = str(uuid.uuid4())
            if is_in_the_second_period and not is_in_the_switchup:
                employee = {
                    "ID": id,
                    "PESEL": pesel,
                    "First Name": first_name,
                    "Last Name": last_name,
                    "Date Of Birth": birthday.strftime("%Y-%m-%d"),
                    "Department": department,
                    "Position": position,
                    "Start": start_of_work.strftime("%Y-%m-%d"),
                    "End": None if is_last_position else (start_of_work + days_at_position).strftime("%Y-%m-%d"),
                    "Wage": wage
                }
                employees_additional.append(employee)
                employees[id] = (False, False, employee)
                employees_all.append(employee)
            elif is_in_the_second_period and is_in_the_switchup:
                employee = {
                    "ID": id,
                    "PESEL": pesel,
                    "First Name": first_name,
                    "Last Name": last_name,
                    "Date Of Birth": birthday.strftime("%Y-%m-%d"),
                    "Department": department,
                    "Position": position,
                    "Start": start_of_work.strftime("%Y-%m-%d"),
                    "End": None,
                    "Wage": wage
                }
                employees_first.append(employee)
                employee = {
                    "ID": id,
                    "PESEL": pesel,
                    "First Name": first_name,
                    "Last Name": last_name,
                    "Date Of Birth": birthday.strftime("%Y-%m-%d"),
                    "Department": department,
                    "Position": position,
                    "Start": start_of_work.strftime("%Y-%m-%d"),
                    "End": None if is_last_position else (start_of_work + days_at_position).strftime("%Y-%m-%d"),
                    "Wage": wage
                }
                employees_updates.append(employee)
                employees[id] = (False, False, employee)
                employees_all.append(employee)
            elif not is_in_the_second_period:
                employee = {
                    "ID": id,
                    "PESEL": pesel,
                    "First Name": first_name,
                    "Last Name": last_name,
                    "Date Of Birth": birthday.strftime("%Y-%m-%d"),
                    "Department": department,
                    "Position": position,
                    "Start": start_of_work.strftime("%Y-%m-%d"),
                    "End": None if is_last_position else (start_of_work + days_at_position).strftime("%Y-%m-%d"),
                    "Wage": wage
                }
                employees_first.append(employee)
                employees[id] = (False, False, employee)
                employees_all.append(employee)
            position = get_next_position(position)
            start_of_work = start_of_work + days_at_position
            wage = get_next_wage(wage, 4000)
            if is_last_position or (start_of_work - birthday).days / 365 > max_age:
                break
    print("All employees generated\n")


def generate_offices():
    for _ in range(office_number):
        office = {
            "ID": str(uuid.uuid4()),
            "Street and House Number": f"{fake.street_name()} {fake.building_number()}",
            "Postal Code": fake.postcode(),
            "City": fake.city()
        }
        offices.append(office)
    print("All offices generated\n")


def generate_customers(customer_number, min_age, max_age, min_year, middle_year, last_year):
    for _ in range(customer_number):
        birthday = fake.date_of_birth(minimum_age=min_age, maximum_age=max_age)
        pesel = generate_pesel(birthday)
        first_name = fake.first_name()
        last_name = fake.last_name()
        id = str(uuid.uuid4())
        customer = {
            "CustomerID": id,
            "FirstName": first_name,
            "LastName": last_name,
            "PESEL": pesel,
            "DateOfBirth": birthday.strftime("%Y-%m-%d")
        }
        if random.random() >= 0.9 * (last_year - middle_year) / (last_year - min_year):
            customers_additional.append(customer)
        else:
            customers_first.append(customer)
            if random.random() <= 0.01:
                if random.random() <= 0.5:
                    first_name = fake.first_name()
                elif random.random() <= 0.9:
                    last_name = fake.last_name()
                else:
                    first_name = fake.first_name()
                    last_name = fake.last_name()
                customer = {
                    "CustomerID": id,
                    "FirstName": first_name,
                    "LastName": last_name,
                    "PESEL": pesel,
                    "DateOfBirth": birthday.strftime("%Y-%m-%d")
                }
                customers_updates.append(customer)
        customers.append(customer)
    print("All customers generated\n")


def generate_policies(customer_number, max_per_customer, middle_year, max_year):
    for i in range(customer_number):
        for _ in range(random.randint(1, max_per_customer)):
            customer = customers[i]
            customer_birth_date = datetime.strptime(customer["DateOfBirth"], "%Y-%m-%d").date()
            customer_adulthood = calculate_adulthood_date(customer_birth_date)
            start_date = random_date(customer_adulthood, date(max_year, 12, 31))
            end_date = random_date(start_date, date(max_year + 20, 12, 31))
            if end_date > date(max_year, 12, 31):
                end_date = date(max_year, 12, 31)
            policy_type = random.choice(list(policy_types.keys()))
            premium_range = policy_types[policy_type]
            factor = (end_date - start_date).days / 365
            premium = generate_weakly_negatively_correlated(premium_range[0], premium_range[1], factor, 0.01)
            policy = {
                "PolicyID": str(uuid.uuid4()),
                "PolicyType": policy_type,
                "PremiumAmount": premium,
                "StartDate": start_date.strftime("%Y-%m-%d"),
                "EndDate": end_date.strftime("%Y-%m-%d"),
                "CustomerID": customer["CustomerID"]
            }
            if start_date >= date(middle_year, 1, 1):
                policies_additional.append(policy)
            else:
                policies_first.append(policy)
            policies.append(policy)
        if i == (customer_number / 10) * int(customer_number / (i + 1)):
            print(i)
            print("policies generated\n")

    print("All policies generated\n")


def generate_claims(evaluators_additional, policies_number, mean_claim_factor, sigma_claims, middle_year, max_year):
    mean_number_of_claims = policies_number * mean_claim_factor

    claimed_policies = random.sample(range(0, policies_number),
                                     int(np.random.normal(mean_number_of_claims, sigma_claims * mean_number_of_claims)))
    for index in claimed_policies:
        policy = policies[index]
        policy_start = datetime.strptime(policy["StartDate"], "%Y-%m-%d").date()
        max_end = date(max_year, 12, 31)
        if policy_start > max_end:
            continue
        start_date = random_date(policy_start, max_end)
        proceeding_days = generate_time_interval(10, 12)
        policy_id = policy["PolicyID"]
        claim_rate = 2000
        claim_amount = int(policy["PremiumAmount"] * random.uniform(1, 2) * random.uniform(1000, claim_rate))
        claim_id = str(uuid.uuid4())
        policy_type = policy["PolicyType"]
        office = random.choice(offices)
        city = office["City"]
        department = city + " - " + policy_type
        candidate_employees = [tuple[2] for tuple in employees.values()]
        department_evaluators = [evaluator for evaluator in candidate_employees if
                                 evaluator["Department"] == department and datetime.strptime(evaluator["Start"],
                                                                                             "%Y-%m-%d").date() <= start_date and (
                                         evaluator["End"] is None or
                                         datetime.strptime(evaluator["End"], "%Y-%m-%d").date() >= start_date)]
        if len(department_evaluators) == 0:
            department_evaluators = [evaluator for evaluator in candidate_employees if
                                     datetime.strptime(evaluator["Start"],
                                                       "%Y-%m-%d").date() <= start_date and (
                                             evaluator["End"] is None or
                                             datetime.strptime(evaluator["End"], "%Y-%m-%d").date() >= start_date)]
            if len(department_evaluators) == 0:
                employee = random.choice(candidate_employees)
            else:
                employee = random.choice(department_evaluators)

        else:
            employee = random.choice(department_evaluators)

        evaluator_position = employee["Position"]
        evaluator_id = employee["ID"]
        if random.random() <= (2 * find_position_index(evaluator_position)) / len(positions):
            result = "1"
        else:
            result = "0"
        if random.random() <= 0.9 * (claim_amount - policy["PremiumAmount"] * claim_rate) / policy[
            "PremiumAmount"] * claim_rate:
            settlement_amount = int(claim_amount / random.uniform(1, 2))
        else:
            settlement_amount = claim_amount

        evaluator = {
            "EvaluatorID": employee["ID"],
            "FirstName": employee["First Name"],
            "LastName": employee["Last Name"],
        }
        if start_date >= date(middle_year, 1, 1):
            if start_date + proceeding_days <= max_end:
                is_resolved = True
                status = "resolved"
            else:
                is_resolved = False
                max_proceeding_days = generate_time_interval(proceeding_days.days, 120)
                status = states_of_claim[int(proceeding_days * (len(states_of_claim) - 1) / max_proceeding_days)]
            claim = {
                "ClaimID": claim_id,
                "PolicyID": policy_id,
                "ClaimAmount": claim_amount,
                "Claim Date": start_date,
                "Result Date": (start_date + proceeding_days).strftime("%Y-%m-%d") if is_resolved else None,
                "Status": status,
                "Result": result if is_resolved else None,
                "EvaluatorID": evaluator_id,
                "OfficeID": office["ID"],
                "SettlementAmount": settlement_amount if is_resolved and result == 1 else None
            }
            claims_additional.append(claim)
            if not employees[evaluator_id][0] and not employees[evaluator_id][1]:
                evaluators_additional.append(evaluator)
                employees[evaluator_id] = (employees[evaluator_id][0], True, employees[evaluator_id][2])
        else:
            if start_date + proceeding_days <= datetime(middle_year - 1, 12, 31).date():
                is_resolved = True
                status = "resolved"
            else:
                is_resolved = False
                max_proceeding_days = generate_time_interval(proceeding_days.days, 120)
                status = states_of_claim[int(proceeding_days * (len(states_of_claim) - 1) / max_proceeding_days)]
            claim = {
                "ClaimID": claim_id,
                "PolicyID": policy_id,
                "ClaimAmount": claim_amount,
                "Claim Date": start_date,
                "Result Date": (start_date + proceeding_days).strftime("%Y-%m-%d") if is_resolved else None,
                "Status": status,
                "Result": result if is_resolved else None,
                "EvaluatorID": evaluator_id,
                "OfficeID": office["ID"],
                "SettlementAmount": settlement_amount if is_resolved and result == 1 else None
            }
            if not employees[evaluator_id][0]:
                evaluators_first.append(evaluator)
                employees[evaluator_id] = (True, employees[evaluator_id][1], employees[evaluator_id][2])
            claims_first.append(claim)
            if not is_resolved:
                claim = {
                    "ClaimID": claim_id,
                    "PolicyID": policy_id,
                    "ClaimAmount": claim_amount,
                    "Claim Date": start_date,
                    "Result Date": (start_date + proceeding_days).strftime("%Y-%m-%d"),
                    "Status": "resolved",
                    "Result": result,
                    "EvaluatorID": evaluator_id,
                    "OfficeID": office["ID"],
                    "SettlementAmount": settlement_amount if result == 1 else None
                }
                claims_updates.append(claim)
    id_to_delete = {item["EvaluatorID"] for item in evaluators_first}
    evaluators_additional[:] = [item for item in evaluators_additional if item["EvaluatorID"] not in id_to_delete]
    print("All claims generated")


begin_year = 1980
middle_year = 2000
end_year = 2024

fake = Faker()
office_number = 100
offices = []
generate_offices()
df = pd.DataFrame(offices)
df.to_excel("offices_data.xlsx", index=False)

policy_types = {'housing': (200, 1500), 'cars': (50, 200), 'health': (100, 300)}
file_path = "offices_data.xlsx"
df = pd.read_excel(file_path, engine='openpyxl')
unique_cities = df['City'].dropna().unique().tolist()
departments = [f"{city} - {department_type}" for city in unique_cities for department_type in policy_types.keys()]

employees = {}
employees_first = []
employees_additional = []
employees_updates = []
employees_all = []
evaluators_first = []
evaluators_additional = []
employee_number = 10000
positions = ['Intern', 'Junior', 'Mid-Level', 'Senior', 'Specialist']

generate_employees(employee_number, 1980, 2022, 2024, 20, 70, 0.05)
df = pd.DataFrame(employees_first)
df.to_excel("employees_first.xlsx", index=False)
df = pd.DataFrame(employees_updates)
df.to_excel("employees_updates.xlsx", index=False)
df = pd.DataFrame(employees_additional)
df.to_excel("employees_additional.xlsx", index=False)
df = pd.DataFrame(employees_all)
df.to_excel("employees_all.xlsx", index=False)

customers = []
customers_first = []
customers_additional = []
customers_updates = []
customer_number = 1000000
generate_customers(customer_number, 20, 100, begin_year, middle_year, end_year)
df = pd.DataFrame(customers_first)
df.to_csv("customers_first.csv", index=False)
df = pd.DataFrame(customers_updates)
df.to_csv("customers_updates.csv", index=False)
df = pd.DataFrame(customers_additional)
df.to_csv("customers_additional.csv", index=False)

policies = []
policies_first = []
policies_additional = []
generate_policies(customer_number, 4, middle_year, end_year)
df = pd.DataFrame(policies_first)
df.to_csv("policies_first.csv", index=False)
df = pd.DataFrame(policies_additional)
df.to_csv("policies_additional.csv", index=False)

states_of_claim = ["received", "pending", "in evalutaion", "proposed", "in dispute", "resolved"]
claims_first = []
claims_additional = []
claims_updates = []
generate_claims(evaluators_additional, len(policies), 0.1, 0.1, middle_year, end_year)
df = pd.DataFrame(claims_first)
df.to_csv("claims_first.csv", index=False)
df = pd.DataFrame(claims_updates)
df.to_csv("claims_updates.csv", index=False)
df = pd.DataFrame(claims_additional)
df.to_csv("claims_additional.csv", index=False)

df = pd.DataFrame(evaluators_first)
df.to_csv("evaluators_first.csv", index=False)
df = pd.DataFrame(evaluators_additional)
df.to_csv("evaluators_additional.csv", index=False)
