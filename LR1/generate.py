import random
import names

def gen_sex():
    if random.randint(0, 1) == 0:
        return 'M'
    else:
        return 'F'

def gen_mail():
    letters = 'abcdefghijklmnopqrstuvwxyz'
    mails = ['@gmail.com', '@yahoo.com', '@outlook.com']
    mail = ''
    length = random.randint(5, 15)
    for i in range(length):
        mail += letters[random.randint(0, 25)]
    mail += mails[random.randint(0, 2)]
    return mail

def gen_date(ymin, ymax):
    date = ''
    year = random.randint(ymin, ymax)
    month = random.randint(1, 12)
    if month in [1, 3, 5, 7, 8, 10, 12]:
        last = 31
    elif month in [4, 6, 9, 11]:
        last = 30
    else:
        if year % 4 == 0:
            last = 29
        else:
            last = 28
    day = random.randint(1, last)
    if day <= 9:
        date = '0'
    if month <= 9:
        date += str(day) + '/0' + str(month) + '/' + str(year)
    else:
        date += str(day) + '/' + str(month) + '/' + str(year)
    return date

def gen_passportno():
    number = random.randint(1, 9)
    for i in range(8):
        number *= 10
        number += random.randint(0, 9)
    return str(number)

    
def gen_unino():
    number = random.randint(1, 9)
    for i in range(5):
        number *= 10
        number += random.randint(0, 9)
    return str(number)

def gen_attno():
    number = random.randint(1, 9)
    for i in range(9):
        number *= 10
        number += random.randint(0, 9)
    return str(number)

def gen_attcode():
    number = random.randint(1, 9)
    for i in range(3):
        number *= 10
        number += random.randint(0, 9)
    return number

def gen_intst(data):
    date = list(data)
    if (int(date[3]) == 0 and int(date[4]) < 9) or (int(date[3]) == 1 and int(date[4]) < 2):
        date[4] = str(int(date[4]) + 1)
    elif (int(date[3]) == 0 and int(date[4]) == 9):
        date[3] = '1'
        date[4] = '0'
    else:
        date[3] = '0'
        date[4] = '1'
        date[9] = str(int(date[9]) + 1)
    data = "".join(date)
    return data


applicants = open('applicants.txt', 'w')
codes = ['SER', 'ITA', 'FRA', 'DEU', 'CHN', 'KOR', 'JPN', 'TUR', 'CAN', 'BRA', 'NGA', 'BGR', 'EGY', 'KAZ', 'THA', 'VNM', 'BLR', 'UKR', 'TCD', 'COL']
for i in range(1, 1051):
    applicants.write(str(i) + '|')  # ApplicantID 
    s = gen_sex()
    if s == "M":
        applicants.write(names.get_first_name(gender='male') + '|')  # FirstName
    else:
        applicants.write(names.get_first_name(gender='female') + '|')  # FirstName
    applicants.write(names.get_last_name() + '|')  # LastName
    applicants.write(gen_date(1990, 2005) + '|') # DOB
    applicants.write(s + '|') # Sex
    applicants.write(gen_mail() + '|')  # Mail
    applicants.write(str(gen_passportno()) + '|')  # PassportNo
    applicants.write(codes[random.randint(0, 19)] + '|') # PassportCode
    applicants.write(gen_date(2012, 2021) + '|') # DateOfIssue
    applicants.write(str(gen_attcode()) + '|') # AttestateNo
    applicants.write(gen_attno() + '\n') # AttestateNo
applicants.close()

schools = open('school.txt', 'w')
old = []
for i in range(1, 1051):
    schools.write(str(i) + '|')  # ApplicantID 
    schools.write(names.get_first_name() + '|')  # LastName
    no = gen_attcode()
    while (no in old):
        no = gen_attcode()
    else:
        schools.write(str(no) + '\n') # AttestateNo
        old.append(no)
schools.close()

cities = ['Belgrade', 'Rome', 'Paris', 'Berlin', 'Beijing', 'Seoul', 'Tokyo', 'Istanbul', 'Toronto', 'Brasilia' , 'Abuja', 
            'Sofia', 'Cairo', 'NurSultan', 'Bangkok', 'Hanoi', 'Minsk', 'Kiev', 'NDjamena', 'Bogota']
unitype = ['full-time', 'online']
specialty = ["IT", "Medicine", "Law", "Economics", "Arts", "Sports", "Linguistics", "History", "Geography", "Philosophy", "Politics", "Architecture"]
studytype = ['old', 'bologna']
universities = open('universities.txt', 'w')
for i in range(1, 1051):
    universities.write(str(i) + '|')  # UniversityID
    universities.write(gen_unino() + '|') #Registration
    universities.write(cities[random.randint(0, 19)] + '|') # City
    universities.write(unitype[random.randint(0, 1)] + '|') # UniType
    universities.write(specialty[random.randint(0, 11)] + '|') # Specialiy
    universities.write(studytype[random.randint(0, 1)] + '|') # StudyType
    universities.write(str(random.randint(100, 350)) + '|') # NeededPoints
    universities.write(gen_mail() + '\n') # UniMail
universities.close()


scholarships = open('scholarships.txt', 'w')
schtype = ['full', 'partial']
education = ['Speciality', 'Bachelor', 'Masters', 'PhD']
accom = ["YES", "NO"]
for i in range(1, 1051):
    scholarships.write(str(i) + '|')  # StudiesID
    scholarships.write(schtype[random.randint(0, 1)] + '|') # ScholarshipType
    rand = random.randint(0, 1)
    scholarships.write(accom[rand] + '|') #Accommodation
    if rand == 1:
        scholarships.write('0' + '|')   #AccPaymenr
    else:
        scholarships.write(str(random.randint(0, 10000)) + '|') #AccPayment
    scholarships.write(str(random.randint(0, 3500)) + '|') #Allowance
    scholarships.write("{:1.2f}".format(random.uniform(3.00, 5.00)) + '|')
    scholarships.write(education[random.randint(0, 3)] + '\n') # Degree
scholarships.close()


applications = open('applications.txt', 'w')
place = ['Center of Science and Culture', 'Embassy']
status = ['accepted', 'denied', 'pending']
for i in range(1, 1051):
    applications.write(str(i) + '|')  # ApplicationsId
    applications.write(str(random.randint(1, 1050)) + '|')  # ApplicantID
    applications.write(str(random.randint(1, 1050)) + '|')  # UniversityID
    applications.write(str(random.randint(1, 1050)) + '|')  # ScholarshipID
    date = gen_date(2021, 2021)
    applications.write(date + '|')  # DateApplied
    applications.write(gen_intst(date) + '|')  # TestDate
    applications.write(place[random.randint(0, 1)] + '|') # TestPlace
    applications.write(status[random.randint(0, 2)] + '\n')  # Status
applications.close()
