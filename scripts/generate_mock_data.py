import json
import random
import os

random.seed(42)

images = [
    "assets/mock/images/car_sedan_red.jpg",
    "assets/mock/images/car_suv_white.jpg",
    "assets/mock/images/car_hatch_blue.jpg",
    "assets/mock/images/car_ev_grey.jpg",
    "assets/mock/images/car_sedan_black.jpg",
    "assets/mock/images/car_wagon_silver.jpg",
]

cities = [
    {"name": "İstanbul", "lat": 41.0082, "lng": 28.9784},
    {"name": "Ankara", "lat": 39.9334, "lng": 32.8597},
    {"name": "İzmir", "lat": 38.4237, "lng": 27.1428},
    {"name": "Bursa", "lat": 40.1885, "lng": 29.0610},
    {"name": "Antalya", "lat": 36.8969, "lng": 30.7133},
    {"name": "Eskişehir", "lat": 39.7767, "lng": 30.5206},
    {"name": "Muğla", "lat": 37.2153, "lng": 28.3636},
    {"name": "Adana", "lat": 37.0000, "lng": 35.3213},
]

catalog = {
    "brands": [
        {"name": "Renault", "models": ["Clio", "Megane", "Captur", "Austral"]},
        {"name": "Fiat", "models": ["Egea Sedan", "Egea Cross", "500L"]},
        {"name": "Volkswagen", "models": ["Golf", "Passat", "Polo", "Tiguan", "T-Roc"]},
        {"name": "Toyota", "models": ["Corolla", "Yaris", "C-HR", "RAV4"]},
        {"name": "Tesla", "models": ["Model Y", "Model 3"]},
        {"name": "BMW", "models": ["320i", "520i", "118i", "X1", "X3"]},
        {"name": "Mercedes-Benz", "models": ["C200", "E200", "A180", "GLA"]},
        {"name": "Hyundai", "models": ["i20", "Tucson", "Elantra", "Bayon"]},
        {"name": "Peugeot", "models": ["208", "308", "2008", "3008"]},
        {"name": "Volvo", "models": ["XC40", "XC60", "S60", "V60"]}
    ],
    "fuelTypes": ["benzin", "dizel", "hibrit", "elektrik", "lpg"],
    "bodyTypes": ["sedan", "hatchback", "suv", "station_wagon", "coupe"],
    "transmissions": ["otomatik", "manuel"],
    "colors": ["Beyaz", "Siyah", "Gri", "Gümüş", "Kırmızı", "Mavi", "Füme"],
    "cities": cities
}

# 18 Users
first_names = ["Ali", "Mehmet", "Ayşe", "Fatma", "Can", "Zeynep", "Burak", "Elif", "Deniz", "Emre", "Selin", "Murat", "Ece", "Oğuz", "Büşra", "Kerem", "Gizem", "Barış"]
last_names = ["Yılmaz", "Demir", "Kaya", "Çelik", "Yıldız", "Öztürk", "Aydın", "Özdemir", "Arslan", "Doğan", "Kılıç", "Aslan", "Çetin", "Kara", "Koç", "Kurt", "Şahin", "Polat"]
professions = ["Yazılım Mühendisi", "Avukat", "Mimar", "Doktor", "Öğretmen", "Grafik Tasarımcı", "Pazarlama Uzmanı", "Finans Analisti", "Makine Mühendisi", "İç Mimar"]
genders = ["Erkek", "Kadın"]
marital_statuses = ["Bekar", "Evli"]

users = []
# Specific test users
test_users = [
    {
        "id": "usr_001",
        "email": "kiraci@test.com",
        "name": "Ali Yılmaz",
        "password": "password123",
        "birthDate": "1994-05-14",
        "profession": "Yazılım Mühendisi",
        "maritalStatus": "Bekar",
        "gender": "Erkek",
        "phone": "+90 532 100 2030",
        "roles": ["renter"],
        "activeRole": "renter",
        "criminalRecordStatus": "verified",
        "avatarUrl": ""
    },
    {
        "id": "usr_002",
        "email": "sahip@test.com",
        "name": "Mehmet Demir",
        "password": "password123",
        "birthDate": "1988-11-23",
        "profession": "Mimar",
        "maritalStatus": "Evli",
        "gender": "Erkek",
        "phone": "+90 533 200 3040",
        "roles": ["owner"],
        "activeRole": "owner",
        "criminalRecordStatus": "verified",
        "avatarUrl": ""
    },
    {
        "id": "usr_003",
        "email": "ikisi@test.com",
        "name": "Ayşe Kaya",
        "password": "password123",
        "birthDate": "1992-08-19",
        "profession": "Doktor",
        "maritalStatus": "Bekar",
        "gender": "Kadın",
        "phone": "+90 535 300 4050",
        "roles": ["renter", "owner"],
        "activeRole": "renter",
        "criminalRecordStatus": "verified",
        "avatarUrl": ""
    }
]

users.extend(test_users)

for i in range(4, 19):
    uid = f"usr_{i:03d}"
    fn = first_names[i-1]
    ln = last_names[i-1]
    name = f"{fn} {ln}"
    email = f"{fn.lower()}.{ln.lower()}@example.com"
    email = email.replace("ı", "i").replace("ğ", "g").replace("ü", "u").replace("ş", "s").replace("ö", "o").replace("ç", "c")
    
    # 2 more dual role users to make >= 3 dual role users
    if i in [4, 5]:
        roles = ["renter", "owner"]
        active_role = "owner" if i == 4 else "renter"
    elif i <= 10:
        roles = ["owner"]
        active_role = "owner"
    else:
        roles = ["renter"]
        active_role = "renter"
        
    users.append({
        "id": uid,
        "email": email,
        "name": name,
        "password": "password123",
        "birthDate": f"{random.randint(1978, 2002)}-{random.randint(1,12):02d}-{random.randint(1,28):02d}",
        "profession": random.choice(professions),
        "maritalStatus": random.choice(marital_statuses),
        "gender": genders[i % 2],
        "phone": f"+90 53{random.randint(0,9)} {random.randint(100,999)} {random.randint(10,99)}{random.randint(10,99)}",
        "roles": roles,
        "activeRole": active_role,
        "criminalRecordStatus": "verified" if random.random() > 0.1 else "none",
        "avatarUrl": ""
    })

# 45 Vehicles
owner_users = [u["id"] for u in users if "owner" in u["roles"]]

vehicle_templates = [
    # brand, model, body, fuel, trans, engineCc, width, weight, seats, consumption, base_price, deposit, km_limit, desc, photo_idx
    ("Renault", "Clio", "hatchback", "benzin", "otomatik", 999, 1798, 1178, 5, 5.2, 1150, 4000, 250, "Şehir içi çok pratik, az yakan, tertemiz ve bakımlı araç.", 2),
    ("Renault", "Megane", "sedan", "dizel", "otomatik", 1461, 1814, 1380, 5, 4.8, 1450, 5000, 300, "Geniş bagaj, konforlu uzun yol aracı. Bakımları yeni yapıldı.", 0),
    ("Renault", "Captur", "suv", "benzin", "otomatik", 1332, 1797, 1310, 5, 5.8, 1550, 5500, 250, "Yüksek sürüş pozisyonu, modern iç mekan ve multimedya ekranı.", 1),
    ("Renault", "Austral", "suv", "hibrit", "otomatik", 1199, 1825, 1517, 5, 4.7, 2600, 10000, 350, "En yeni nesil hibrit SUV, üst düzey konfor ve güvenlik donanımları.", 1),
    ("Fiat", "Egea Sedan", "sedan", "dizel", "manuel", 1248, 1792, 1280, 5, 4.5, 950, 3500, 300, "Ekonomik, geniş aile aracı. Sorunsuz ve yakıt cimrisi.", 4),
    ("Fiat", "Egea Cross", "suv", "hibrit", "otomatik", 1469, 1818, 1375, 5, 5.1, 1300, 4500, 250, "Yükseltilmiş şasi, şık tasarım ve akıcı otomatik vites.", 1),
    ("Volkswagen", "Golf", "hatchback", "benzin", "otomatik", 1498, 1789, 1340, 5, 5.4, 1850, 7000, 300, "Alman kalitesi ve konforu. Apple CarPlay ve dijital kokpit mevcut.", 2),
    ("Volkswagen", "Passat", "sedan", "dizel", "otomatik", 1968, 1832, 1530, 5, 5.1, 2400, 9000, 350, "Makam konforu, uzun yolculukların vazgeçilmez amiral gemisi.", 4),
    ("Volkswagen", "Tiguan", "suv", "benzin", "otomatik", 1498, 1839, 1510, 5, 6.7, 2700, 10000, 300, "Geniş iç mekan, panoramik cam tavan ve mükemmel yol tutuşu.", 1),
    ("Volkswagen", "T-Roc", "suv", "benzin", "otomatik", 1498, 1819, 1350, 5, 6.1, 2100, 8000, 250, "Dinamik kompakt SUV, çevik ve sportif sürüş.", 1),
    ("Toyota", "Corolla", "sedan", "hibrit", "otomatik", 1798, 1780, 1385, 5, 4.1, 1600, 6000, 300, "Dünyanın en çok satan modeli. Sorunsuz hibrit motor, sessiz sürüş.", 0),
    ("Toyota", "Yaris", "hatchback", "hibrit", "otomatik", 1490, 1745, 1160, 5, 3.8, 1350, 4500, 250, "Şehir trafiğinde sıfır stres ve inanılmaz düşük yakıt tüketimi.", 2),
    ("Toyota", "C-HR", "suv", "hibrit", "otomatik", 1798, 1795, 1420, 5, 4.3, 1950, 7500, 250, "Fütüristik tasarım, sessiz elektrikli kalkış, keyifli sürüş.", 1),
    ("Tesla", "Model Y", "suv", "elektrik", "otomatik", None, 1921, 1979, 5, None, 3900, 15000, 400, "Tam elektrikli, otopilot, süper şarj uyumlu, cam tavan.", 3),
    ("Tesla", "Model 3", "sedan", "elektrik", "otomatik", None, 1849, 1765, 5, None, 3400, 12000, 400, "İnanılmaz ivmelenme, minimalist iç mekan, üst düzey teknoloji.", 3),
    ("BMW", "320i", "sedan", "benzin", "otomatik", 1597, 1827, 1565, 5, 6.5, 3200, 12000, 300, "M Sport paket, üstün dinamizm ve sürüş keyfi.", 0),
    ("BMW", "520i", "sedan", "benzin", "otomatik", 1597, 1868, 1690, 5, 6.8, 4200, 15000, 350, "Executive lüks sedan, Harman Kardon ses sistemi ve vakumlu kapılar.", 4),
    ("BMW", "X1", "suv", "benzin", "otomatik", 1499, 1845, 1575, 5, 6.4, 3100, 11000, 300, "Kompakt lüks SUV, xLine paket, geniş bagaj hacmi.", 1),
    ("Mercedes-Benz", "C200", "sedan", "hibrit", "otomatik", 1496, 1820, 1650, 5, 6.2, 3600, 14000, 300, "AMG paket, ambiyans aydınlatma, lüks ve zarafet bir arada.", 4),
    ("Mercedes-Benz", "E200", "sedan", "benzin", "otomatik", 1991, 1852, 1735, 5, 7.2, 4500, 18000, 350, "Kusursuz konfor, havalı süspansiyon hissi ve prestij.", 4),
    ("Mercedes-Benz", "GLA", "suv", "benzin", "otomatik", 1332, 1834, 1485, 5, 6.3, 2900, 10000, 300, "Şehirli lüks crossover, yüksek tavan ve MBUX sesli asistan.", 1),
    ("Hyundai", "i20", "hatchback", "benzin", "otomatik", 1197, 1775, 1142, 5, 5.7, 1100, 3500, 250, "Yeni kasa, şık ön ızgara, kablosuz şarj ve geniş ekran.", 2),
    ("Hyundai", "Tucson", "suv", "dizel", "otomatik", 1598, 1865, 1600, 5, 5.9, 2500, 9000, 300, "Cesur geometrik tasarım, 4x4 çekiş gücü, ferah aile aracı.", 1),
    ("Peugeot", "208", "hatchback", "benzin", "otomatik", 1199, 1745, 1165, 5, 5.0, 1250, 4000, 250, "i-Cockpit küçük direksiyon, aslan pençesi LED farlar.", 2),
    ("Peugeot", "3008", "suv", "dizel", "otomatik", 1499, 1842, 1504, 5, 5.2, 2400, 8500, 300, "Grip Control, masajlı koltuk, ödüllü ergonomik kokpit.", 1),
    ("Volvo", "XC40", "suv", "hibrit", "otomatik", 1477, 1863, 1812, 5, 5.5, 3300, 12000, 300, "İskandinav güvenliği ve konforu. Google dahili işletim sistemi.", 1),
    ("Volvo", "V60", "station_wagon", "hibrit", "otomatik", 1969, 1850, 1800, 5, 5.6, 3100, 11000, 350, "Geniş bagajlı estetik aile vagonu. Bow & Wilkins ses sistemi.", 5),
]

vehicles = []
v_id = 1

# Generate 45 vehicles
for i in range(45):
    tmpl = vehicle_templates[i % len(vehicle_templates)]
    brand, model, btype, fuel, trans, cc, width, weight, seats, cons, base_price, base_dep, base_km, desc, photo_idx = tmpl
    
    # Year: 2018 to 2024
    year = random.choice([2019, 2020, 2021, 2022, 2023, 2024])
    # Age derived
    age = 2026 - year
    km = int(age * random.uniform(11000, 22000) + random.randint(1000, 8000))
    
    # Adjust price based on year and km
    year_factor = 1.0 + (year - 2020) * 0.08
    km_factor = 1.0 - (km / 300000.0) * 0.15
    price = int(round(base_price * year_factor * km_factor / 50.0) * 50)
    deposit = int(round(base_dep * year_factor / 100.0) * 100)
    
    city_info = cities[i % len(cities)]
    owner_id = owner_users[i % len(owner_users)]
    
    # Random minor offset for lat/lng to scatter in the city
    lat = round(city_info["lat"] + random.uniform(-0.06, 0.06), 4)
    lng = round(city_info["lng"] + random.uniform(-0.06, 0.06), 4)
    
    # Photos array: 3-5 photos cycling through images
    assigned_photos = [images[photo_idx]]
    extra_photo1 = images[(photo_idx + 1) % len(images)]
    extra_photo2 = images[(photo_idx + 2) % len(images)]
    assigned_photos.extend([extra_photo1, extra_photo2])
    
    color = random.choice(["Beyaz", "Siyah", "Gri", "Gümüş", "Kırmızı", "Mavi", "Füme"])
    
    vehicles.append({
        "id": f"veh_{v_id:03d}",
        "ownerId": owner_id,
        "brand": brand,
        "model": model,
        "modelYear": year,
        "km": km,
        "fuelType": fuel,
        "bodyType": btype,
        "transmission": trans,
        "color": color,
        "engineCc": cc,
        "widthMm": width,
        "weightKg": weight,
        "seats": seats,
        "fuelConsumption": cons,
        "dailyPrice": price,
        "deposit": deposit,
        "dailyKmLimit": base_km,
        "minRentalDays": random.choice([1, 2, 3]),
        "maxRentalDays": random.choice([15, 30, 45]),
        "city": city_info["name"],
        "lat": lat,
        "lng": lng,
        "photos": assigned_photos,
        "status": "active" if i > 3 else ("rented" if i == 0 else ("paused" if i == 1 else "active")),
        "description": desc,
        # Derived fields to be recalculated
        "uniqueRenterCount": 0,
        "completedRentalCount": 0,
        "ratingAvg": 0.0,
        "ratingCount": 0,
        "popularityScore": 0.0
    })
    v_id += 1

# 35 Rentals
renter_users = [u["id"] for u in users if "renter" in u["roles"]]

rentals = []
r_id = 1

# Past dates for completed rentals
completed_rental_data = [
    # (veh_idx, renter_idx, days_ago, duration_days)
    (0, 0, 90, 4),
    (0, 2, 50, 3),
    (1, 1, 110, 5),
    (1, 3, 30, 2),
    (2, 4, 75, 7),
    (3, 0, 40, 3),
    (4, 5, 120, 6),
    (5, 6, 85, 4),
    (6, 2, 60, 5),
    (7, 7, 100, 3),
    (8, 0, 25, 4),
    (9, 8, 45, 2),
    (10, 1, 95, 6),
    (11, 3, 70, 3),
    (12, 4, 115, 5),
    (13, 2, 35, 4),
    (14, 5, 80, 7),
    (15, 6, 65, 3),
    (16, 7, 55, 4),
    (17, 0, 15, 2),
    (18, 8, 105, 5),
    (19, 1, 40, 3),
    (20, 3, 50, 4),
    (21, 4, 85, 6),
    (22, 5, 70, 2),
    (23, 6, 30, 5),
    (24, 7, 90, 4),
    (25, 8, 110, 3),
    (26, 0, 60, 5),
    (27, 2, 45, 4),
]

for veh_idx, ren_idx, days_ago, dur in completed_rental_data:
    veh = vehicles[veh_idx]
    renter_id = renter_users[ren_idx % len(renter_users)]
    # Ensure owner != renter
    if renter_id == veh["ownerId"]:
        renter_id = [r for r in renter_users if r != veh["ownerId"]][0]
        
    start_day = days_ago
    end_day = days_ago - dur
    
    start_date = f"2026-07-{max(1, min(28, 30 - (start_day % 28))):02d}"
    end_date = f"2026-07-{max(1, min(28, 30 - (end_day % 28))):02d}"
    if start_date > end_date:
        start_date, end_date = end_date, start_date
        
    rentals.append({
        "id": f"rent_{r_id:03d}",
        "vehicleId": veh["id"],
        "ownerId": veh["ownerId"],
        "renterId": renter_id,
        "startDate": f"2026-08-{max(1, (r_id * 2) % 25 + 1):02d}",
        "endDate": f"2026-08-{max(2, (r_id * 2) % 25 + dur + 1):02d}",
        "dailyPrice": veh["dailyPrice"],
        "totalDays": dur,
        "totalPrice": veh["dailyPrice"] * dur,
        "deposit": veh["deposit"],
        "status": "completed",
        "createdAt": "2026-08-01T10:00:00Z"
    })
    r_id += 1

# Active rentals (2-3)
active_veh = vehicles[0]
renter_for_active = [r for r in renter_users if r != active_veh["ownerId"]][0]
rentals.append({
    "id": f"rent_{r_id:03d}",
    "vehicleId": active_veh["id"],
    "ownerId": active_veh["ownerId"],
    "renterId": renter_for_active,
    "startDate": "2026-10-18",
    "endDate": "2026-10-24",
    "dailyPrice": active_veh["dailyPrice"],
    "totalDays": 6,
    "totalPrice": active_veh["dailyPrice"] * 6,
    "deposit": active_veh["deposit"],
    "status": "active",
    "createdAt": "2026-10-17T12:00:00Z"
})
r_id += 1

# Pending offers/rentals (2-3)
pending_veh = vehicles[2]
renter_for_pending = [r for r in renter_users if r != pending_veh["ownerId"]][1]
rentals.append({
    "id": f"rent_{r_id:03d}",
    "vehicleId": pending_veh["id"],
    "ownerId": pending_veh["ownerId"],
    "renterId": renter_for_pending,
    "startDate": "2026-11-01",
    "endDate": "2026-11-05",
    "dailyPrice": pending_veh["dailyPrice"],
    "totalDays": 4,
    "totalPrice": pending_veh["dailyPrice"] * 4,
    "deposit": pending_veh["deposit"],
    "status": "pending_confirmation",
    "createdAt": "2026-10-19T09:30:00Z"
})
r_id += 1

# 65+ Reviews
reviews = []
rev_id = 1

renter_comments = [
    "Araç pırıl pırıldı, sahibi teslim alırken çok yardımcı oldu. Kesinlikle tekrar kiralayacağım.",
    "Sorunsuz bir kiralama deneyimi oldu. Araç tam ilan fotoğraflarındaki gibiydi.",
    "Yakıt tüketimi gerçekten çok düşüktü. Araç sahibi çok kibar ve anlayışlı bir beyefendi.",
    "Çok memnun kaldım. Uzun yolda konforu harikaydı, hiçbir problem yaşamadık.",
    "Zamanında teslim aldım, araç içi temizlik 10 numaraydı. Güvenle tercih edebilirsiniz.",
    "Araç mekanik olarak kusursuzdu. İletişim hızlı ve şeffaftı. Teşekkürler!",
    "Ailemizle harika bir tatil geçirdik, bagaj kapasitesi tam yetti. Tavsiye ederim.",
    "Performansı ve sürüş keyfi beklentimin üzerindeydi. Süreç çok hızlı ilerledi."
]

owner_comments = [
    "Aracı tertemiz ve vaktinde teslim etti. Çok saygılı ve güvenilir bir kiracı.",
    "Kurallara tam uydu, depoyu dolu teslim etti. Her zaman kapımız açık.",
    "Çok memnun kaldık, iletişimi güçlü ve özenli bir kullanıcı. Gönül rahatlığıyla araç verilir.",
    "Araca kendi aracı gibi iyi baktı. Sorunsuz bir kiralama süreci oldu.",
    "Saygılı ve dakik bir misafirimiz oldu. Tekrar bekleriz."
]

# Generate reviews for completed rentals (leave 3 completed rentals without reviews to test "Değerlendir" flow!)
completed_rentals = [r for r in rentals if r["status"] == "completed"]

for idx, r in enumerate(completed_rentals):
    # Leave last 3 unreviewed for testing "Değerlendirme bekliyor"
    if idx >= len(completed_rentals) - 3:
        continue
        
    # Renter reviews Owner & Vehicle
    r_stars = random.choice([4, 5, 5, 5, 4, 3, 5])
    v_stars = max(1, min(5, r_stars + random.choice([-1, 0, 0, 1])))
    reviews.append({
        "id": f"rev_{rev_id:03d}",
        "rentalId": r["id"],
        "vehicleId": r["vehicleId"],
        "reviewerId": r["renterId"],
        "targetId": r["ownerId"],
        "targetRole": "owner",
        "stars": r_stars,
        "vehicleStars": v_stars,
        "comment": random.choice(renter_comments),
        "createdAt": "2026-08-15T14:20:00Z"
    })
    rev_id += 1
    
    # Owner reviews Renter (most of the time)
    if random.random() > 0.15:
        o_stars = random.choice([4, 5, 5, 5, 5, 4])
        reviews.append({
            "id": f"rev_{rev_id:03d}",
            "rentalId": r["id"],
            "vehicleId": r["vehicleId"],
            "reviewerId": r["ownerId"],
            "targetId": r["renterId"],
            "targetRole": "renter",
            "stars": o_stars,
            "vehicleStars": None,
            "comment": random.choice(owner_comments),
            "createdAt": "2026-08-16T11:00:00Z"
        })
        rev_id += 1

# Recalculate derived statistics for vehicles
for v in vehicles:
    v_rentals = [r for r in rentals if r["vehicleId"] == v["id"] and r["status"] == "completed"]
    v["completedRentalCount"] = len(v_rentals)
    unique_renters = set(r["renterId"] for r in v_rentals)
    v["uniqueRenterCount"] = len(unique_renters)
    
    # Reviews on this vehicle
    v_reviews = [rev for rev in reviews if rev.get("vehicleId") == v["id"] and rev.get("vehicleStars") is not None]
    if v_reviews:
        v["ratingCount"] = len(v_reviews)
        v["ratingAvg"] = round(sum(rev["vehicleStars"] for rev in v_reviews) / len(v_reviews), 1)
    else:
        # If no direct vehicle reviews yet, provide realistic default starting stats
        v["ratingCount"] = random.randint(3, 8)
        v["ratingAvg"] = round(random.uniform(4.5, 5.0), 1)
        v["completedRentalCount"] = max(v["completedRentalCount"], random.randint(2, 6))
        v["uniqueRenterCount"] = max(v["uniqueRenterCount"], v["completedRentalCount"])
        
    # Popularity score: (completed rentals * 3) + (ratingAvg * 10) + (unique renters * 2)
    v["popularityScore"] = round((v["completedRentalCount"] * 3.0) + (v["ratingAvg"] * 10.0) + (v["uniqueRenterCount"] * 2.0), 1)

# Recalculate user profiles
for u in users:
    uid = u["id"]
    # Renter stats
    renter_rents = [r for r in rentals if r["renterId"] == uid and r["status"] == "completed"]
    renter_revs = [rev for rev in reviews if rev["targetId"] == uid and rev["targetRole"] == "renter"]
    
    renter_avg = round(sum(rev["stars"] for rev in renter_revs) / len(renter_revs), 1) if renter_revs else 4.9
    renter_cnt = len(renter_revs) if renter_revs else len(renter_rents)
    
    if "renter" in u["roles"]:
        u["renterProfile"] = {
            "rentedCount": len(renter_rents),
            "ratingAvg": renter_avg,
            "ratingCount": renter_cnt
        }
    else:
        u["renterProfile"] = None
        
    # Owner stats
    owner_vehs = [v for v in vehicles if v["ownerId"] == uid]
    owner_rents = [r for r in rentals if r["ownerId"] == uid and r["status"] == "completed"]
    owner_revs = [rev for rev in reviews if rev["targetId"] == uid and rev["targetRole"] == "owner"]
    
    owner_avg = round(sum(rev["stars"] for rev in owner_revs) / len(owner_revs), 1) if owner_revs else 4.8
    owner_cnt = len(owner_revs) if owner_revs else len(owner_rents)
    
    if "owner" in u["roles"]:
        u["ownerProfile"] = {
            "listingCount": len(owner_vehs),
            "rentedOutCount": len(owner_rents),
            "ratingAvg": owner_avg,
            "ratingCount": owner_cnt
        }
    else:
        u["ownerProfile"] = None

# 8 Chats with messages and offers
chats = []
chat_configs = [
    (0, "usr_001", "usr_002", "veh_001"), # Ali (renter) & Mehmet (owner) on Renault Clio
    (1, "usr_003", "usr_002", "veh_002"), # Ayşe (renter) & Mehmet (owner) on Megane
    (2, "usr_001", "usr_004", "veh_004"), # Ali (renter) & Oğuz (owner) on Austral
    (3, "usr_006", "usr_002", "veh_001"), # Burak & Mehmet
    (4, "usr_007", "usr_005", "veh_007"), # Elif & Selin
    (5, "usr_008", "usr_004", "veh_009"), # Deniz & Oğuz
    (6, "usr_009", "usr_002", "veh_002"), # Emre & Mehmet
    (7, "usr_003", "usr_005", "veh_014"), # Ayşe & Selin on Tesla
]

c_id = 1
for idx, renter_id, owner_id, v_id_str in chat_configs:
    veh = next(v for v in vehicles if v["id"] == v_id_str)
    
    chat_messages = [
        {
            "id": f"msg_{c_id}_1",
            "senderId": renter_id,
            "type": "text",
            "text": f"Merhaba! {veh['brand']} {veh['model']} aracınız için rezervasyon yaptırmak istiyorum, müsait midir?",
            "createdAt": "2026-10-19T10:15:00Z",
            "read": True,
            "offer": None
        },
        {
            "id": f"msg_{c_id}_2",
            "senderId": owner_id,
            "type": "text",
            "text": "Merhaba, evet belirtilen tarihler için aracım tamamen müsaittir.",
            "createdAt": "2026-10-19T10:18:00Z",
            "read": True,
            "offer": None
        },
        {
            "id": f"msg_{c_id}_3",
            "senderId": renter_id,
            "type": "offer",
            "text": f"{veh['dailyPrice']} TL günlük fiyattan 3 günlük kiralama teklifi gönderildi.",
            "createdAt": "2026-10-19T10:20:00Z",
            "read": True,
            "offer": {
                "startDate": "2026-11-05",
                "endDate": "2026-11-08",
                "dailyPrice": veh["dailyPrice"],
                "totalPrice": veh["dailyPrice"] * 3,
                "status": "pending" if idx == 0 else "accepted"
            }
        }
    ]
    
    if idx > 0:
        chat_messages.append({
            "id": f"msg_{c_id}_4",
            "senderId": owner_id,
            "type": "text",
            "text": "Teklifinizi onayladım! Kiralama detayları ve teslim noktası için görüşmek üzere.",
            "createdAt": "2026-10-19T10:25:00Z",
            "read": True,
            "offer": None
        })
        
    chats.append({
        "id": f"chat_{c_id:03d}",
        "vehicleId": v_id_str,
        "ownerId": owner_id,
        "renterId": renter_id,
        "lastMessage": chat_messages[-1]["text"],
        "unreadCount": 1 if idx == 0 else 0,
        "updatedAt": chat_messages[-1]["createdAt"],
        "messages": chat_messages
    })
    c_id += 1

# Write to assets/mock/
os.makedirs("assets/mock", exist_ok=True)

with open("assets/mock/catalog.json", "w", encoding="utf-8") as f:
    json.dump(catalog, f, ensure_ascii=False, indent=2)

with open("assets/mock/users.json", "w", encoding="utf-8") as f:
    json.dump(users, f, ensure_ascii=False, indent=2)

with open("assets/mock/vehicles.json", "w", encoding="utf-8") as f:
    json.dump(vehicles, f, ensure_ascii=False, indent=2)

with open("assets/mock/rentals.json", "w", encoding="utf-8") as f:
    json.dump(rentals, f, ensure_ascii=False, indent=2)

with open("assets/mock/reviews.json", "w", encoding="utf-8") as f:
    json.dump(reviews, f, ensure_ascii=False, indent=2)

with open("assets/mock/chats.json", "w", encoding="utf-8") as f:
    json.dump(chats, f, ensure_ascii=False, indent=2)

print(f"Generated successfully:")
print(f"- Users: {len(users)}")
print(f"- Vehicles: {len(vehicles)}")
print(f"- Rentals: {len(rentals)}")
print(f"- Reviews: {len(reviews)}")
print(f"- Chats: {len(chats)}")
