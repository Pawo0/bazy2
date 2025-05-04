# Dokumentowe bazy danych – MongoDB

Ćwiczenie/zadanie


---

**Imiona i nazwiska autorów:**

--- 

Odtwórz z backupu bazę north0

```
mongorestore --nsInclude='north0.*' ./dump/
```

```
use north0
```


# Zadanie 1 - operacje wyszukiwania danych,  przetwarzanie dokumentów

# a)

stwórz kolekcję  `OrdersInfo`  zawierającą następujące dane o zamówieniach
- pojedynczy dokument opisuje jedno zamówienie

```js
[  
  {  
    "_id": ...
    
    OrderID": ... numer zamówienia
    
    "Customer": {  ... podstawowe informacje o kliencie skladającym  
      "CustomerID": ... identyfikator klienta
      "CompanyName": ... nazwa klienta
      "City": ... miasto 
      "Country": ... kraj 
    },  
    
    "Employee": {  ... podstawowe informacje o pracowniku obsługującym zamówienie
      "EmployeeID": ... idntyfikator pracownika 
      "FirstName": ... imie   
      "LastName": ... nazwisko
      "Title": ... stanowisko  
     
    },  
    
    "Dates": {
       "OrderDate": ... data złożenia zamówienia
       "RequiredDate": data wymaganej realizacji
    }

    "Orderdetails": [  ... pozycje/szczegóły zamówienia - tablica takich pozycji 
      {  
        "UnitPrice": ... cena
        "Quantity": ... liczba sprzedanych jednostek towaru
        "Discount": ... zniżka  
        "Value": ... wartośc pozycji zamówienia
        "product": { ... podstawowe informacje o produkcie 
          "ProductID": ... identyfikator produktu  
          "ProductName": ... nazwa produktu 
          "QuantityPerUnit": ... opis/opakowannie
          "CategoryID": ... identyfikator kategorii do której należy produkt
          "CategoryName" ... nazwę tej kategorii
        },  
      },  
      ...   
    ],  

    "Freight": ... opłata za przesyłkę
    "OrderTotal"  ... sumaryczna wartosc sprzedanych produktów

    "Shipment" : {  ... informacja o wysyłce
        "Shipper": { ... podstawowe inf o przewoźniku 
           "ShipperID":  
            "CompanyName":
        }  
        ... inf o odbiorcy przesyłki
        "ShipName": ...
        "ShipAddress": ...
        "ShipCity": ... 
        "ShipCountry": ...
    } 
  } 
]  
```

# b)

stwórz kolekcję  `CustomerInfo`  zawierającą następujące dane kazdym klencie
- pojedynczy dokument opisuje jednego klienta

```js
[  
  {  
    "_id": ...
    
    "CustomerID": ... identyfikator klienta
    "CompanyName": ... nazwa klienta
    "City": ... miasto 
    "Country": ... kraj 

	"Orders": [ ... tablica zamówień klienta o strukturze takiej jak w punkcie a) (oczywiście bez informacji o kliencie)
	  
	]

		  
]  
```

# c) 

Napisz polecenie/zapytanie: Dla każdego klienta pokaż wartość zakupionych przez niego produktów z kategorii 'Confections'  w 1997r
- Spróbuj napisać to zapytanie wykorzystując
	- oryginalne kolekcje (`customers, orders, orderdertails, products, categories`)
	- kolekcję `OrderInfo`
	- kolekcję `CustomerInfo`

- porównaj zapytania/polecenia/wyniki

```js
[  
  {  
    "_id": 
    
    "CustomerID": ... identyfikator klienta
    "CompanyName": ... nazwa klienta
	"ConfectionsSale97": ... wartość zakupionych przez niego produktów z kategorii 'Confections'  w 1997r

  }		  
]  
```

# d)

Napisz polecenie/zapytanie:  Dla każdego klienta poaje wartość sprzedaży z podziałem na lata i miesiące
Spróbuj napisać to zapytanie wykorzystując
	- oryginalne kolekcje (`customers, orders, orderdertails, products, categories`)
	- kolekcję `OrderInfo`
	- kolekcję `CustomerInfo`

- porównaj zapytania/polecenia/wyniki

```js
[  
  {  
    "_id": 
    
    "CustomerID": ... identyfikator klienta
    "CompanyName": ... nazwa klienta

	"Sale": [ ... tablica zawierająca inf o sprzedazy
	    {
            "Year":  ....
            "Month": ....
            "Total": ...	    
	    }
	    ...
	]
  }		  
]  
```

# e)

Załóżmy że pojawia się nowe zamówienie dla klienta 'ALFKI',  zawierające dwa produkty 'Chai' oraz "Ikura"
- pozostałe pola w zamówieniu (ceny, liczby sztuk prod, inf o przewoźniku itp. możesz uzupełnić wg własnego uznania)
Napisz polecenie które dodaje takie zamówienie do bazy
- aktualizując oryginalne kolekcje `orders`, `orderdetails`
- aktualizując kolekcję `OrderInfo`
- aktualizując kolekcję `CustomerInfo`

Napisz polecenie 
- aktualizując oryginalną kolekcję orderdetails`
- aktualizując kolekcję `OrderInfo`
- aktualizując kolekcję `CustomerInfo`

# f)

Napisz polecenie które modyfikuje zamówienie dodane w pkt e)  zwiększając zniżkę  o 5% (dla każdej pozycji tego zamówienia) 

Napisz polecenie 
- aktualizując oryginalną kolekcję `orderdetails`
- aktualizując kolekcję `OrderInfo`
- aktualizując kolekcję `CustomerInfo`



UWAGA:
W raporcie należy zamieścić kod poleceń oraz uzyskany rezultat, np wynik  polecenia `db.kolekcka.fimd().limit(2)` lub jego fragment


## Zadanie 1  - rozwiązanie

> Wyniki: 
> 
> przykłady, kod, zrzuty ekranów, komentarz ...

a)

```js
db.orders.aggregate([
  { $match: {} },

  {
    $lookup: {
      from: "customers",
      localField: "CustomerID",
      foreignField: "CustomerID",
      as: "Customer"
    }
  },
  { $unwind: { path: "$Customer", preserveNullAndEmptyArrays: true } },

  {
    $lookup: {
      from: "employees",
      localField: "EmployeeID",
      foreignField: "EmployeeID",
      as: "Employee"
    }
  },
  { $unwind: { path: "$Employee", preserveNullAndEmptyArrays: true } },

  {
    $lookup: {
      from: "Dates",
      localField: "OrderDate",
      foreignField: "OrderDate",
      as: "Dates"
    }
  },
  { $unwind: { path: "$Dates", preserveNullAndEmptyArrays: true } },

  {
    $lookup: {
      from: "orderdetails",
      localField: "OrderID",
      foreignField: "OrderID",
      as: "Orderdetails"
    }
  },

{
  $lookup: {
    from: "products",
    localField: "Orderdetails.ProductID",
    foreignField: "ProductID",
    as: "Products"
  }
},
{
  $lookup: {
    from: "categories",
    localField: "Products.CategoryID",
    foreignField: "CategoryID",
    as: "Categories"
  }
},
  {
  $addFields: {
    Orderdetails: {
      $map: {
        input: "$Orderdetails",
        as: "item",
        in: {
          UnitPrice: "$$item.UnitPrice",
          Quantity: "$$item.Quantity",
          Discount: "$$item.Discount",
          Value: {
            $multiply: [
              { $multiply: ["$$item.UnitPrice", "$$item.Quantity"] },
              { $subtract: [1, "$$item.Discount"] }
            ]
          },
          product: {
            $let: {
              vars: {
                prod: {
                  $arrayElemAt: [
                    {
                      $filter: {
                        input: "$Products",
                        as: "p",
                        cond: { $eq: ["$$p.ProductID", "$$item.ProductID"] }
                      }
                    }, 0
                  ]
                }
              },
              in: {
                ProductID: "$$prod.ProductID",
                ProductName: "$$prod.ProductName",
                QuantityPerUnit: "$$prod.QuantityPerUnit",
                CategoryID: "$$prod.CategoryID",
                CategoryName: {
                  $let: {
                    vars: {
                      cat: {
                        $arrayElemAt: [
                          {
                            $filter: {
                              input: "$Categories",
                              as: "c",
                              cond: { $eq: ["$$c.CategoryID", "$$prod.CategoryID"] }
                            }
                          }, 0
                        ]
                      }
                    },
                    in: "$$cat.CategoryName"
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  },

  {
    $lookup: {
      from: "Shippment",  
      localField: "ShipmentID",
      foreignField: "ShipmentID",
      as: "Shipment"
    }
  },
  { $unwind: { path: "$Shipment", preserveNullAndEmptyArrays: true } },
  
  {
    $lookup: {
      from: "shippers",
      localField: "ShipVia",
      foreignField: "ShipperID",
      as: "Shipper"
    }
  },

  { $unwind: { path: "$Shipper", preserveNullAndEmptyArrays: true } },

  {
  $addFields: {
    Shipment: {
      Shipper: {
        ShipperID: "$Shipper.ShipperID",
        CompanyName: "$Shipper.CompanyName"
      },
      ShipName: "$Shipment.ShipName",
      ShipAddress: "$Shipment.ShipAddress",
      ShipCity: "$Shipment.ShipCity",
      ShipCountry: "$Shipment.ShipCountry"
    }
  }
  },

  {
    $addFields: {
        OrderTotal: {
        $sum: {
          $map: {
            input: "$Orderdetails",
            as: "item",
            in: {
              $multiply: [
                { $multiply: ["$$item.UnitPrice", "$$item.Quantity"] },
                { $subtract: [1, "$$item.Discount"] }
              ]
            }
          }
        }
      }
    }
  },

  {
  $project: {
    _id: 0,
    OrderID: 1,
    Orderdetails: 1,
    Dates: {
      OrderDate: 1,
      RequiredDate: 1
    },
    Employee: {
      EmployeeID: 1,
      FirstName: 1,
      LastName: 1,
      Title: 1
    },
    Customer: {
      CustomerID: 1,
      City: 1,
      CompanyName: 1,
      Country: 1
    },
    Shipment: {
      Shipper: {
        ShipperID: 1,
        CompanyName: 1
      },
      ShipName: 1,
      ShipAddress: 1,
      ShipCity: 1,
      ShipCountry: 1
    },
    Freight: 1,
    OrderTotal: 1
  }
  }
  ,
  {
    $out: "OrdersInfo"
  }
]);
```
```js

```

b)

```js
db.OrdersInfo.aggregate([
  {
    $group: {
      _id: "$Customer.CustomerID",
      CustomerID: { $first: "$Customer.CustomerID" },
      CompanyName: { $first: "$Customer.CompanyName" },
      City: { $first: "$Customer.City" },
      Country: { $first: "$Customer.Country" },
      Orders: { $push: 
      {
        OrderID:"$OrderID",
        Freight: "$Freight",
        OrderTotal: "$OrderTotal",
        Dates:"$Dates",
        Shipment: "$Shipment",
        Employee:"$Employee",
        Orderdetails: "$Orderdetails"
      }
      }
    }
  },
  { $out: "CustomerInfo" }
]);

```

c)

```js
-- z oryginalnych kolekcji --

db.customers.aggregate([
  {
    $lookup: {
      from: "orders",
      localField: "CustomerID",
      foreignField: "CustomerID",
      as: "orders"
    }
  },
  { $unwind: "$orders" },
  {
    $match: {
      "orders.OrderDate": {
        $gte: new ISODate("1997-01-01"),
        $lt: new ISODate("1998-01-01")
      }
    }
  },
  {
    $lookup: {
      from: "orderdetails",
      localField: "orders.OrderID",
      foreignField: "OrderID",
      as: "details"
    }
  },
  { $unwind: "$details" },
  {
    $lookup: {
      from: "products",
      localField: "details.ProductID",
      foreignField: "ProductID",
      as: "product"
    }
  },
  { $unwind: "$product" },
  {
    $lookup: {
      from: "categories",
      localField: "product.CategoryID",
      foreignField: "CategoryID",
      as: "category"
    }
  },
  { $unwind: "$category" },
  {
    $match: { "category.CategoryName": "Confections" }
  },
  {
    $group: {
      _id: "$CustomerID",
      CompanyName: { $first: "$CompanyName" },
      ConfectionsSale97: {
        $sum: {
          $multiply: [
            "$details.UnitPrice",
            "$details.Quantity",
            { $subtract: [1, "$details.Discount"] }
          ]
        }
      }
    }
  }
]);

```

d)
```js
-- z oryginalnych kolekcji --

db.customers.aggregate([
  {
    $lookup: {
      from: "orders",
      localField: "CustomerID",
      foreignField: "CustomerID",
      as: "orders"
    }
  },
  { $unwind: "$orders" },
  {
    $lookup: {
      from: "orderdetails",
      localField: "orders.OrderID",
      foreignField: "OrderID",
      as: "details"
    }
  },
  { $unwind: "$details" },
  {
    $group: {
      _id: {
        CustomerID: "$CustomerID",
        CompanyName: "$CompanyName",
        Year: { $year: "$orders.OrderDate" },
        Month: { $month: "$orders.OrderDate" }
      },
      Total: {
        $sum: {
          $multiply: [
            "$details.UnitPrice",
            "$details.Quantity",
            { $subtract: [1, "$details.Discount"] }
          ]
        }
      }
    }
  },
  {
    $group: {
      _id: "$_id.CustomerID",
      CustomerID: { $first: "$_id.CustomerID" },
      CompanyName: { $first: "$_id.CompanyName" },
      Sale: {
        $push: {
          Year: "$_id.Year",
          Month: "$_id.Month",
          Total: "$Total"
        }
      }
    }
  },
  {
    $project: {
      _id: 0,
      CustomerID: 1,
      CompanyName: 1,
      Sale: 1
    }
  }
]);


```

....

# Zadanie 2 - modelowanie danych


Zaproponuj strukturę bazy danych dla wybranego/przykładowego zagadnienia/problemu

Należy wybrać jedno zagadnienie/problem (A lub B lub C)

Przykład A
- Wykładowcy, przedmioty, studenci, oceny
	- Wykładowcy prowadzą zajęcia z poszczególnych przedmiotów
	- Studenci uczęszczają na zajęcia
	- Wykładowcy wystawiają oceny studentom
	- Studenci oceniają zajęcia

Przykład B
- Firmy, wycieczki, osoby
	- Firmy organizują wycieczki
	- Osoby rezerwują miejsca/wykupują bilety
	- Osoby oceniają wycieczki

Przykład C
- Własny przykład o podobnym stopniu złożoności

a) Zaproponuj  różne warianty struktury bazy danych i dokumentów w poszczególnych kolekcjach oraz przeprowadzić dyskusję każdego wariantu (wskazać wady i zalety każdego z wariantów)
- zdefiniuj schemat/reguły walidacji danych
- wykorzystaj referencje
- dokumenty zagnieżdżone
- tablice

b) Kolekcje należy wypełnić przykładowymi danymi

c) W kontekście zaprezentowania wad/zalet należy zaprezentować kilka przykładów/zapytań/operacji oraz dla których dedykowany jest dany wariant

W sprawozdaniu należy zamieścić przykładowe dokumenty w formacie JSON ( pkt a) i b)), oraz kod zapytań/operacji (pkt c)), wraz z odpowiednim komentarzem opisującym strukturę dokumentów oraz polecenia ilustrujące wykonanie przykładowych operacji na danych

Do sprawozdania należy kompletny zrzut wykonanych/przygotowanych baz danych (taki zrzut można wykonać np. za pomocą poleceń `mongoexport`, `mongdump` …) oraz plik z kodem operacji/zapytań w wersji źródłowej (np. plik .js, np. plik .md ), załącznik powinien mieć format zip

## Zadanie 2  - rozwiązanie

> Wyniki: 
> 
> przykłady, kod, zrzuty ekranów, komentarz ...

---

## Warianty struktury danych

### Wariant 1: Kolekcje rozdzielone, połączone referencjami

Struktura oparta na osobnych kolekcjach z referencjami do obiektów w innych kolekcjach. Idealna do sytuacji, gdzie dane są często aktualizowane i analizowane oddzielnie.

#### Struktura kolekcji:

* `pracownicy`: przechowuje dane personalne pracowników

  ```json
  {
    "_id": ObjectId(),
    "imie": "Tomasz",
    "nazwisko": "Kowalski",
    "email": "t.kowalski@firma.pl",
  	"telefon": "+48 600 987 654",
  	"ranga": "administrator"
  }
  ```

* `klienci`: dane kontaktowe i identyfikacyjne klientów

  ```json
  {
    "_id": ObjectId(),
    "imie": "Anna",
    "nazwisko": "Nowak",
    "email": "anna.nowak@example.com",
  	"telefon": "+48 501 234 567",
  	"ranga": "premium",
  	"adres": {
    	"ulica": "Lipowa 12",
    	"miasto": "Warszawa",
    	"kod_pocztowy": "00-123"
  	}
  }
  ```

* `produkty`: płyty z filmami lub muzyką wraz z informacją o stanie magazynowym

  ```json
  {
    "_id": ObjectId(),
    "tytul": "Incepcja",
    "typ": "film",
    "kategoria": "sci-fi",
    "ilosc_w_magazynie": 10,
    "ilosc_zarezerwowana": 2,
    "ilosc_wypozyczona": 3
  }
  ```

* `zamowienia`: informacje o wypożyczeniach i rezerwacjach z referencją do klienta, pracownika i produktów

  ```json
  {
    "_id": ObjectId(),
    "klient_id": ObjectId(),
    "pracownik_id": ObjectId(),
    "produkty": [
      {
        "produkt_id": ObjectId(),
        "typ": "wypozyczenie",
        "data_start": ISODate(),
        "data_koniec": ISODate()
      }
    ],
    "status": "aktywny"
  }
  ```

* `oceny`: zawiera oceny wystawione przez klientów dla produktów

  ```json
  {
    "_id": ObjectId(),
    "klient_id": ObjectId(),
    "produkt_id": ObjectId(),
    "ocena": 5,
    "komentarz": "Świetny film!"
  }
  ```

#### Zalety i wady

**Zalety:** przejrzystość, łatwa rozbudowa, dobra wydajność przy dużych zbiorach.

**Wady:** konieczność użycia agregacji lub joinów (\$lookup), większa liczba zapytań.

---

### Wariant 2: Dokumenty zagnieżdżone

Dane o zamówieniach i ocenach przechowywane są bezpośrednio w dokumencie klienta.

#### Struktura kolekcji:

* `klienci`:

```json
{
	"_id": ObjectId(),
	"imie": "Anna",
	"nazwisko": "Nowak",
	"email": "anna.nowak@example.com",
	"telefon": "+48 501 234 567",
	"ranga": "premium",
	"adres": {
		"ulica": "Lipowa 12",
		"miasto": "Warszawa",
		"kod_pocztowy": "00-123"
	},
	"zamowienia": [
	  {
		"produkt_id": ObjectId("665000000000000000000001"),
		"typ": "wypozyczenie",
		"data_start": ISODate("2025-05-01T00:00:00Z"),
		"data_koniec": ISODate("2025-05-10T00:00:00Z")
	  }
	],
	"oceny": [
	  {
		"produkt_id": ObjectId("665000000000000000000001"),
		"ocena": 5,
		"komentarz": "Super!"
	  }
	]
 }
```

* `produkty`, `pracownicy`: jak w wariancie 1

#### Zalety i wady

**Zalety:** szybki dostęp do danych klienta, uproszczone odczyty.

**Wady:** ograniczenia rozmiaru dokumentu, utrudniona aktualizacja.

---

### Wariant 3: Kolekcja działań (event sourcing)

Wszystkie akcje w systemie reprezentowane są przez dokumenty w jednej kolekcji `dzialania`.

#### Struktura kolekcji:

* `dzialania`:

  ```json
  {
    "_id": ObjectId(),
    "typ": "rezerwacja",
    "klient_id": ObjectId(),
    "produkt_id": ObjectId(),
    "data": ISODate(),
    "szczegoly": {
      "data_koniec": ISODate(),
      "pracownik_id": ObjectId()
    }
  }
  ```

* `produkty`, `klienci`, `pracownicy`: jak w wariancie 1

#### Zalety i wady

**Zalety:** dobra baza do analizy zachowań użytkownika, logi systemowe.

**Wady:** trudniejsze wyszukiwanie danych semantycznych, więcej filtrów.

---

### Wariant 4: Hybrydowy

Połączenie podejścia referencyjnego i zagnieżdżonego.

#### Struktura kolekcji:

* `produkty`: produkt zawiera ocenę w zagnieżdżonej tablicy

  ```json
  {
    "_id": ObjectId(),
    "tytul": "Matrix",
    "oceny": [
      {
        "klient_id": ObjectId(),
        "ocena": 5,
        "komentarz": "Klasyk!"
      }
    ]
  }
  ```

* `zamowienia`, `klienci`, `pracownicy`: jak w wariancie 1

#### Zalety i wady

**Zalety:** zoptymalizowane pod kątem szybkości i skalowalności.

**Wady:** konieczność synchronizacji danych między kolekcjami.

---

## Porównanie zapytań dla różnych wariantów struktur danych

---

## **Wariant 1: Referencyjny**

Dane przechowywane w osobnych kolekcjach: `klienci`, `pracownicy`, `produkty`, `zamowienia`, `oceny`.

### Przykładowe zapytania:

1. **Wyszukanie zamówień danego klienta z produktami:**

```js
db.zamowienia.aggregate([
  { $match: { klient_id: ObjectId("665...002") } },
  {
    $lookup: {
      from: "produkty",
      localField: "produkty.produkt_id",
      foreignField: "_id",
      as: "szczegoly_produktow"
    }
  }
])
```

2. **Średnia ocena danego produktu:**

```js
db.oceny.aggregate([
  { $match: { produkt_id: ObjectId("665...001") } },
  { $group: { _id: "$produkt_id", srednia: { $avg: "$ocena" } } }
])
```

3. **Lista premium klientów z Warszawy:**

```js
db.klienci.find({
  ranga: "premium",
  "adres.miasto": "Warszawa"
})
```

### Wnioski:

| Kryterium                  | Ocena                          |
| -------------------------- | ------------------------------ |
| Czytelność                 | 🟡 średnia                     |
| Złożoność                  | 🔴 wysoka (`$lookup`)          |
| Wydajność                  | 🔴 niższa przy dużych zbiorach |
| Skalowalność               | 🟢 bardzo dobra                |
| Łatwość modyfikacji danych | 🟢 wysoka                      |

---

## **Wariant 2: Dokumenty zagnieżdżone**

Dane powiązane (zamówienia, oceny) są częścią dokumentu klienta.

### Przykładowe zapytania:

1. **Wszystkie zamówienia klienta:**

```js
db.klienci.find(
  { _id: ObjectId("665...002") },
  { zamowienia: 1 }
)
```

2. **Dodanie nowej oceny klienta:**

```js
db.klienci.updateOne(
  { _id: ObjectId("665...002") },
  {
    $push: {
      oceny: {
        produkt_id: ObjectId("665...001"),
        ocena: 5,
        komentarz: "Rewelacyjny film!"
      }
    }
  }
)
```

3. **Średnia ocen (trudniejsze):**

```js
// Potrzebna transformacja w kodzie aplikacji po stronie klienta
```

### Wnioski:

| Kryterium                  | Ocena                                   |
| -------------------------- | --------------------------------------- |
| Czytelność                 | 🟢 wysoka                               |
| Złożoność                  | 🟢 niska                                |
| Wydajność                  | 🟢 dobra przy małych dokumentach        |
| Skalowalność               | 🔴 słaba (limity dokumentu)             |
| Łatwość modyfikacji danych | 🔴 niska (nadpisywanie całych struktur) |

---

## **Wariant 3: Event sourcing (kolekcja `dzialania`)**

Wszystkie operacje (rezerwacje, wypożyczenia, oceny) są zapisane jako osobne zdarzenia w jednej kolekcji.

### Przykładowe zapytania:

1. **Zdarzenia klienta:**

```js
db.dzialania.find({ klient_id: ObjectId("665...002") })
```

2. **Wszystkie rezerwacje dla danego produktu:**

```js
db.dzialania.find({
  produkt_id: ObjectId("665...001"),
  typ: "rezerwacja"
})
```

3. **Ilość wypożyczeń filmu w maju:**

```js
db.dzialania.countDocuments({
  typ: "wypozyczenie",
  data: { $gte: ISODate("2025-05-01"), $lt: ISODate("2025-06-01") }
})
```

### Wnioski:

| Kryterium                  | Ocena                   |
| -------------------------- | ----------------------- |
| Czytelność                 | 🟡 średnia              |
| Złożoność                  | 🟡 średnia              |
| Wydajność                  | 🟢 dobra na działaniach |
| Skalowalność               | 🟢 bardzo dobra         |
| Łatwość modyfikacji danych | 🟢 bardzo wysoka        |

---

## **Wariant 4: Hybrydowy**

Część danych zagnieżdżona (np. oceny w produktach), część jako referencje (np. zamówienia).

### Przykładowe zapytania:

1. **Oceny dla filmu bez dodatkowego `lookup`:**

```js
db.produkty.find(
  { _id: ObjectId("665...001") },
  { oceny: 1 }
)
```

2. **Zamówienia klienta (referencja):**

```js
db.zamowienia.find({ klient_id: ObjectId("665...002") })
```

3. **Średnia ocena z zagnieżdżonych ocen:**

```js
db.produkty.aggregate([
  { $match: { _id: ObjectId("665...001") } },
  { $unwind: "$oceny" },
  { $group: { _id: "$_id", srednia: { $avg: "$oceny.ocena" } } }
])
```

### Wnioski:

| Kryterium                  | Ocena                                 |
| -------------------------- | ------------------------------------- |
| Czytelność                 | 🟢 dobra                              |
| Złożoność                  | 🟡 umiarkowana                        |
| Wydajność                  | 🟢 wysoka dla często używanych danych |
| Skalowalność               | 🟡 zależy od modelu                   |
| Łatwość modyfikacji danych | 🟡 średnia                            |

---

## **Porównanie końcowe**

| Kryterium               | Wariant 1 (Referencje) | Wariant 2 (Zagnieżdżone) | Wariant 3 (Event sourcing) | Wariant 4 (Hybrydowy) |
| ----------------------- | ---------------------- | ------------------------ | -------------------------- | --------------------- |
| Szybkość dostępu        | 🔴                     | 🟢                       | 🟡                         | 🟢                    |
| Prostota zapytań        | 🔴                     | 🟢                       | 🟡                         | 🟢                    |
| Skalowalność            | 🟢                     | 🔴                       | 🟢                         | 🟡                    |
| Elastyczność            | 🟡                     | 🔴                       | 🟢                         | 🟢                    |
| Nadaje się do analityki | 🟢                     | 🔴                       | 🟢                         | 🟢                    |

---





Punktacja:

|         |     |
| ------- | --- |
| zadanie | pkt |
| 1       | 1   |
| 2       | 1   |
| razem   | 2   |



