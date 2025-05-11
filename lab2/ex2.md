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
    db.createCollection("pracownicy", {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["imie", "nazwisko", "email", "telefon", "ranga"],
          properties: {
            _id: {
              bsonType: "objectId"
            },
            imie: {
              bsonType: "string",
              description: "Imię pracownika - pole wymagane"
            },
            nazwisko: {
              bsonType: "string",
              description: "Nazwisko pracownika - pole wymagane"
            },
            email: {
              bsonType: "string",
              pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
              description: "Email pracownika w poprawnym formacie - pole wymagane"
            },
            telefon: {
              bsonType: "string",
              pattern: "^\\+[0-9]{2}\\s[0-9]{3}\\s[0-9]{3}\\s[0-9]{3}$",
              description: "Numer telefonu w formacie +XX XXX XXX XXX - pole wymagane"
            },
            ranga: {
              bsonType: "string",
              enum: ["administrator", "pracownik", "manager"],
              description: "Ranga pracownika (administrator, pracownik lub manager) - pole wymagane"
            }
          }
        }
      }
    });
  ```

* `klienci`: dane kontaktowe i identyfikacyjne klientów

  ```json
    db.createCollection("klienci", {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["imie", "nazwisko", "email", "telefon", "ranga"],
          properties: {
            _id: {
              bsonType: "objectId"
            },
            imie: {
              bsonType: "string",
              description: "Imię klienta - pole wymagane"
            },
            nazwisko: {
              bsonType: "string",
              description: "Nazwisko klienta - pole wymagane"
            },
            email: {
              bsonType: "string",
              pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
              description: "Email klienta w poprawnym formacie - pole wymagane"
            },
            telefon: {
              bsonType: "string",
              pattern: "^\\+[0-9]{2}\\s[0-9]{3}\\s[0-9]{3}\\s[0-9]{3}$",
              description: "Numer telefonu w formacie +XX XXX XXX XXX - pole wymagane"
            },
            ranga: {
              bsonType: "string",
              enum: ["standard", "premium", "vip"],
              description: "Ranga klienta - pole wymagane"
            },
            adres: {
              bsonType: "object",
              required: ["ulica", "miasto", "kod_pocztowy"],
              properties: {
                ulica: {
                  bsonType: "string",
                  description: "Ulica i numer budynku"
                },
                miasto: {
                  bsonType: "string",
                  description: "Miasto"
                },
                kod_pocztowy: {
                  bsonType: "string",
                  pattern: "^[0-9]{2}-[0-9]{3}$",
                  description: "Kod pocztowy w formacie XX-XXX"
                }
              }
            }
          }
        }
      }
    });
  ```

* `produkty`: płyty z filmami lub muzyką wraz z informacją o stanie magazynowym

  ```json

    db.createCollection("produkty", {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["tytul", "typ", "kategoria", "ilosc_w_magazynie"],
          properties: {
            _id: {
              bsonType: "objectId"
            },
            nazwa: {
              bsonType: "string",
              description: "Nazwa produktu - pole wymagane"
            },
            typ: {
              bsonType: "string",
              enum: ["film", "muzyka", "audiobook", "kaseta"],
              description: "Typ produktu - pole wymagane"
            },
            kategoria: {
              bsonType: "string",
              description: "Kategoria produktu - pole wymagane"
            },
            ilosc_w_magazynie: {
              bsonType: "int",
              minimum: 0,
              description: "Ilość produktów w magazynie - pole wymagane"
            },
            ilosc_zarezerwowana: {
              bsonType: "int",
              minimum: 0,
              description: "Ilość zarezerwowanych produktów"
            },
            ilosc_wypozyczona: {
              bsonType: "int",
              minimum: 0,
              description: "Ilość wypożyczonych produktów"
            }
          }
        }
      }
    });

  ```

* `zamowienia`: informacje o wypożyczeniach i rezerwacjach z referencją do klienta, pracownika i produktów

  ```json

    db.createCollection("zamowienia", {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["klient_id", "pracownik_id", "produkty", "status"],
          properties: {
            _id: {
              bsonType: "objectId"
            },
            klient_id: {
              bsonType: "objectId",
              description: "ID klienta - pole wymagane"
            },
            pracownik_id: {
              bsonType: "objectId",
              description: "ID pracownika - pole wymagane"
            },
            produkty: {
              bsonType: "array",
              minItems: 1,
              items: {
                bsonType: "object",
                required: ["produkt_id", "typ", "data_start"],
                properties: {
                  produkt_id: {
                    bsonType: "objectId",
                    description: "ID produktu - pole wymagane"
                  },
                  typ: {
                    bsonType: "string",
                    enum: ["wypozyczenie", "rezerwacja"],
                    description: "Typ zamówienia - pole wymagane"
                  },
                  data_start: {
                    bsonType: "date",
                    description: "Data rozpoczęcia - pole wymagane"
                  },
                  data_koniec: {
                    bsonType: "date",
                    description: "Data zakończenia "
                  }
                }
              }
            },
            status: {
              bsonType: "string",
              enum: ["aktywny", "zakończony", "anulowany"],
              description: "Status zamówienia - pole wymagane"
            }
          }
        }
      }
    });
  ```

* `oceny`: zawiera oceny wystawione przez klientów dla produktów

  ```json

    db.createCollection("oceny", {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["klient_id", "produkt_id", "ocena"],
          properties: {
            _id: {
              bsonType: "objectId"
            },
            klient_id: {
              bsonType: "objectId",
              description: "ID klienta - pole wymagane"
            },
            produkt_id: {
              bsonType: "objectId",
              description: "ID produktu - pole wymagane"
            },
            ocena: {
              bsonType: "int",
              minimum: 1,
              maximum: 5,
              description: "Ocena w skali 1-5 - pole wymagane"
            },
            komentarz: {
              bsonType: "string",
              description: "Komentarz do oceny"
            }
          }
        }
      }
    });
  ```

#### Zalety i wady

**Zalety:** przejrzystość, łatwa rozbudowa, dobra wydajność przy dużych zbiorach.

**Wady:** konieczność użycia agregacji lub joinów, większa liczba zapytań.

---

### Wariant 2: Dokumenty zagnieżdżone

Dane o zamówieniach i ocenach przechowywane są bezpośrednio w dokumencie klienta.

#### Struktura kolekcji:

* `klienci`:

```json
    db.createCollection("klienci_nested", {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["imie", "nazwisko", "email", "telefon", "ranga"],
          properties: {
            _id: {
              bsonType: "objectId"
            },
            imie: {
              bsonType: "string",
              description: "Imię klienta - pole wymagane"
            },
            nazwisko: {
              bsonType: "string", 
              description: "Nazwisko klienta - pole wymagane"
            },
            email: {
              bsonType: "string",
              pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
              description: "Email klienta w poprawnym formacie - pole wymagane"
            },
            telefon: {
              bsonType: "string",
              pattern: "^\\+[0-9]{2}\\s[0-9]{3}\\s[0-9]{3}\\s[0-9]{3}$",
              description: "Numer telefonu w formacie +XX XXX XXX XXX - pole wymagane"
            },
            ranga: {
              bsonType: "string",
              enum: ["standard", "premium", "vip"],
              description: "Ranga klienta - pole wymagane"
            },
            adres: {
              bsonType: "object",
              required: ["ulica", "miasto", "kod_pocztowy"],
              properties: {
                ulica: {
                  bsonType: "string",
                  description: "Ulica i numer budynku"
                },
                miasto: {
                  bsonType: "string",
                  description: "Miasto"
                },
                kod_pocztowy: {
                  bsonType: "string",
                  pattern: "^[0-9]{2}-[0-9]{3}$",
                  description: "Kod pocztowy w formacie XX-XXX"
                }
              }
            },
            zamowienia: {
              bsonType: "array",
              items: {
                bsonType: "object",
                required: ["produkt_id", "typ", "data_start", "data_koniec"],
                properties: {
                  produkt_id: {
                    bsonType: "objectId",
                    description: "ID produktu - pole wymagane"
                  },
                  typ: {
                    bsonType: "string",
                    enum: ["wypozyczenie", "rezerwacja"],
                    description: "Typ zamówienia - pole wymagane"
                  },
                  data_start: {
                    bsonType: "date",
                    description: "Data rozpoczęcia - pole wymagane"
                  },
                  data_koniec: {
                    bsonType: "date",
                    description: "Data zakończenia - pole wymagane"
                  }
                }
              }
            },
            oceny: {
              bsonType: "array",
              items: {
                bsonType: "object",
                required: ["produkt_id", "ocena"],
                properties: {
                  produkt_id: {
                    bsonType: "objectId",
                    description: "ID produktu - pole wymagane"
                  },
                  ocena: {
                    bsonType: "int",
                    minimum: 1,
                    maximum: 5,
                    description: "Ocena w skali 1-5 - pole wymagane"
                  },
                  komentarz: {
                    bsonType: "string",
                    description: "Komentarz do oceny"
                  }
                }
              }
            }
          }
        }
      }
    });
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
    db.createCollection("dzialania", {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["typ_zdarzenia", "data_zdarzenia", "obiekt_id"],
          properties: {
            _id: {
              bsonType: "objectId"
            },
            typ_zdarzenia: {
              bsonType: "string",
              enum: ["wypozyczenie", "rezerwacja", "zwrot", "ocena", "rejestracja", "anulowanie", "zmiana_statusu"],
              description: "Typ zdarzenia w systemie - pole wymagane"
            },
            data_zdarzenia: {
              bsonType: "date",
              description: "Data i czas zdarzenia - pole wymagane"
            },
            obiekt_id: {
              bsonType: "objectId",
              description: "ID głównego obiektu, którego dotyczy zdarzenie - pole wymagane"
            },
            klient_id: {
              bsonType: "objectId",
              description: "ID klienta, który wykonał akcję"
            },
            pracownik_id: {
              bsonType: "objectId",
              description: "ID pracownika obsługującego zdarzenie"
            },
            produkt_id: {
              bsonType: "objectId",
              description: "ID produktu, którego dotyczy zdarzenie"
            },
            dane_zdarzenia: {
              bsonType: "object",
              properties: {
                ocena: {
                  bsonType: "int",
                  minimum: 1,
                  maximum: 5,
                  description: "Ocena przyznana produktowi (1-5)"
                },
                komentarz: {
                  bsonType: "string",
                  description: "Komentarz dodany do oceny"
                },
                nowy_status: {
                  bsonType: "string",
                  enum: ["aktywny", "zakończony", "anulowany"],
                  description: "Nowy status zamówienia po zmianie"
                },
                data_start: {
                  bsonType: "date",
                  description: "Data rozpoczęcia wypożyczenia/rezerwacji"
                },
                data_koniec: {
                  bsonType: "date",
                  description: "Data zakończenia wypożyczenia/rezerwacji"
                },
                dane_klienta: {
                  bsonType: "object",
                  description: "Dane klienta przy rejestracji lub aktualizacji"
                },
                dane_pracownika: {
                  bsonType: "object",
                  description: "Dane pracownika przy rejestracji lub aktualizacji"
                },
                dane_produktu: {
                  bsonType: "object",
                  description: "Dane produktu podczas dodawania lub aktualizacji"
                }
              }
            }
          }
        }
      }
    });
  ```

* `produkty`, `klienci`, `pracownicy`: jak w wariancie 1

#### Zalety i wady

**Zalety:** dobra baza do analizy zachowań użytkownika, logi systemowe.

**Wady:** trudniejsze wyszukiwanie danych semantycznych, więcej filtrów.

---

### Wariant 4: Hybrydowy

Połączenie podejścia referencyjnego i zagnieżdżonego.

#### Struktura kolekcji:

* `klienci`: jak w wariancie 1, ale zagnieżdżone zamówienia z nazwa produktu i oceny bez komentarza

```json
    db.createCollection("klienci_hybrid", {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["imie", "nazwisko", "email", "telefon", "ranga"],
          properties: {
            _id: {
              bsonType: "objectId"
            },
            imie: {
              bsonType: "string",
              description: "Imię klienta - pole wymagane"
            },
            nazwisko: {
              bsonType: "string", 
              description: "Nazwisko klienta - pole wymagane"
            },
            email: {
              bsonType: "string",
              pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
              description: "Email klienta w poprawnym formacie - pole wymagane"
            },
            telefon: {
              bsonType: "string",
              pattern: "^\\+[0-9]{2}\\s[0-9]{3}\\s[0-9]{3}\\s[0-9]{3}$",
              description: "Numer telefonu w formacie +XX XXX XXX XXX - pole wymagane"
            },
            ranga: {
              bsonType: "string",
              enum: ["standard", "premium", "vip"],
              description: "Ranga klienta - pole wymagane"
            },
            adres: {
              bsonType: "object",
              required: ["ulica", "miasto", "kod_pocztowy"],
              properties: {
                ulica: {
                  bsonType: "string",
                  description: "Ulica i numer budynku"
                },
                miasto: {
                  bsonType: "string",
                  description: "Miasto"
                },
                kod_pocztowy: {
                  bsonType: "string",
                  pattern: "^[0-9]{2}-[0-9]{3}$",
                  description: "Kod pocztowy w formacie XX-XXX"
                }
              }
            },
            zamowienia: {
              bsonType: "array",
              items: {
                bsonType: "object",
                required: ["produkt_id", "typ", "data_start", "data_koniec"],
                properties: {
                  produkt_id: {
                    bsonType: "objectId",
                    description: "ID produktu - pole wymagane"
                  },
                  product_name: {
                    bsonType: "string",
                    description: "Nazwa produktu (czesto uzywana)"
                  },
                  typ: {
                    bsonType: "string",
                    enum: ["wypozyczenie", "rezerwacja"],
                    description: "Typ zamówienia - pole wymagane"
                  },
                  data_start: {
                    bsonType: "date",
                    description: "Data rozpoczęcia - pole wymagane"
                  },
                  data_koniec: {
                    bsonType: "date",
                    description: "Data zakończenia - pole wymagane"
                  }
                }
              }
            },
            oceny: {
              bsonType: "array",
              items: {
                bsonType: "object",
                required: ["ocena_id", "produkt_id", "ocena"],
                properties: {
                  ocena_id: {
                    bsonType: "objectId",
                    description: "ID oceny - pole wymagane"
                  },
                  produkt_id: {
                    bsonType: "objectId",
                    description: "ID produktu - pole wymagane"
                  },
                  ocena: {
                    bsonType: "int",
                    minimum: 1,
                    maximum: 5,
                    description: "Ocena w skali 1-5 - pole wymagane"
                  }
                }
              }
            }
          }
        }
      }
    });

```

* `produkty, oceny, pracownicy` - jak w wariancie 1


#### Zalety i wady

**Zalety:** zoptymalizowane pod kątem szybkości i skalowalności.

**Wady:** konieczność synchronizacji danych między kolekcjami, stworzenie funkcji aktualizujących dane.

---

## Dodanie przykładowych danych

---
### Wariant 1: Kolekcje rozdzielone, połączone referencjami

```js


// dodawanie danych do kolekcji
db.klienci.insertMany(
[{
    "imie": "Jan",
    "nazwisko": "Kowalski",
    "email": "jan.kowalski@gmail.com",
    "telefon": "+48 123 456 789",
    "ranga": "standard",
    "adres": {
        "ulica": "Kwiatowa 5",
        "miasto": "Warszawa",
        "kod_pocztowy": "00-001"
    }
},
{
    "imie": "Anna",
    "nazwisko": "Nowak",
    "email": "ann@gmail.com",
    "telefon": "+48 789 456 123",
    "ranga": "premium",
    "adres": {
        "ulica": "Długa 15",
        "miasto": "Kraków",
        "kod_pocztowy": "30-001"
    }
}
]
)

db.pracownicy.insertMany(
[{
    "imie": "Adam",
    "nazwisko": "Nowak",
    "email": "adam@gmail.com",
    "telefon": "+48 987 654 321",
    "ranga": "administrator"
},
    {
      "imie": "Marta",
      "nazwisko": "Kowalska",
      "email": "marta.kowalska@wypozyczalnia.pl",
      "telefon": "+48 987 654 321",
      "ranga": "pracownik"
    }
]
)

db.produkty.insertMany(
[
 {
      tytul: "Inception",
      typ: "film",
      kategoria: "sci-fi",
      ilosc_w_magazynie: 8,
      ilosc_zarezerwowana: 1,
      ilosc_wypozyczona: 2
    },
    {
      tytul: "The Dark Side of the Moon",
      typ: "muzyka",
      kategoria: "rock",
      ilosc_w_magazynie: 5,
      ilosc_zarezerwowana: 0,
      ilosc_wypozyczona: 3
    },
    {
      tytul: "Harry Potter i Kamień Filozoficzny",
      typ: "audiobook",
      kategoria: "fantasy",
      ilosc_w_magazynie: 3,
      ilosc_zarezerwowana: 1,
      ilosc_wypozyczona: 1
    }
]
)

let klient = db.klienci.findOne({"email": "jan.kowalski@gmail.com"})
let pracownik = db.pracownicy.findOne({"email": "adam@gmail.com"})
let produkt = db.produkty.findOne({"tytul": "Film A"})

db.zamowienia.insertOne({
    "klient_id": klient._id,
    "pracownik_id": pracownik._id,
    "produkty": [
        {
            "produkt_id": produkt._id,
            "typ": "wypozyczenie",
            "data_start": new Date()
        }
    ],
    "status": "aktywny"
})
```

### Wariant 2: Dokumenty zagnieżdżone

* `produkty`, `pracownicy`: jak w wariancie 1

```js

// dane do zagniezdzonej kolekcji
let produkty = db.produkty.find().toArray();
let produktId = produkty.map(p => p._id);
print(produktId);

db.klienci_nested.insertMany([
  {
    "imie": "Jan",
    "nazwisko": "Kowalski",
    "email": "jan.kowalski@gmail.com",
    "telefon": "+48 123 456 789",
    "ranga": "standard",
    "adres": {
      "ulica": "Kwiatowa 5",
      "miasto": "Warszawa",
      "kod_pocztowy": "00-001"
    },
    "zamowienia": [
      {
        "produkt_id": produktId[0],
        "typ": "wypozyczenie",
        "data_start": new Date(),
        "data_koniec": new Date(new Date().getTime() + 7*24*60*60*1000)
      }
    ],
    "oceny": [
      {
        "produkt_id": produktId[0],
        "ocena": 5,
        "komentarz": "Świetny film, polecam!"
      }
    ]
  },
  {
    "imie": "Anna",
    "nazwisko": "Nowak",
    "email": "anna.nowak@gmail.com",
    "telefon": "+48 789 456 123",
    "ranga": "premium",
    "adres": {
      "ulica": "Długa 15",
      "miasto": "Kraków",
      "kod_pocztowy": "30-001"
    },
    "zamowienia": [
      {
        "produkt_id": produktId[1],
        "typ": "wypozyczenie",
        "data_start":  new Date(),
        "data_koniec":  new Date(new Date().getTime() + 7*24*60*60*1000)
      },
      {
        "produkt_id": produktId[2],
        "typ": "rezerwacja",
        "data_start":  new Date(),
        "data_koniec":  new Date(new Date().getTime() + 7*24*60*60*1000)
      }
    ],
    "oceny": [
      {
        "produkt_id": produktId[1],
        "ocena": 4,
        "komentarz": "Dobry album, ale mogłoby być więcej utworów"
      }
    ]
  },
  {
    "imie": "Piotr",
    "nazwisko": "Wiśniewski",
    "email": "piotr.wisniewski@gmail.com",
    "telefon": "+48 555 666 777",
    "ranga": "vip",
    "adres": {
      "ulica": "Szeroka 8",
      "miasto": "Gdańsk",
      "kod_pocztowy": "80-001"
    },
    "zamowienia": [
      {
        "produkt_id": produktId[0],
        "typ": "wypozyczenie",
        "data_start": new Date(),
        "data_koniec":  new Date(new Date().getTime() + 7*24*60*60*1000)
      },
      {
        "produkt_id": produktId[1],
        "typ": "wypozyczenie",
        "data_start": new Date(),
        "data_koniec": new Date(new Date().getTime() + 7*24*60*60*1000)
      },
      {
        "produkt_id": produktId[2],
        "typ": "wypozyczenie",
        "data_start": new Date(),
        "data_koniec":  new Date(new Date().getTime() + 7*24*60*60*1000)
      }
    ],
    "oceny": [
      {
        "produkt_id": produktId[0],
        "ocena": 3,
        "komentarz": "Film przeciętny, ale daje się obejrzeć"
      },
      {
        "produkt_id": produktId[1],
        "ocena": 5,
        "komentarz": "Fantastyczny album, słucham codziennie!"
      },
      {
        "produkt_id": produktId[2],
        "ocena": 4,
        "komentarz": "Ciekawa książka, wciągająca fabuła"
      }
    ]
  }
]);
```

### Wariant 3: Kolekcja działań (event sourcing)
* `produkty`, `klienci`, `pracownicy`: jak w wariancie 1

```js


// Pobierz istniejące dane z innych kolekcji
let klienci = db.klienci.find().toArray();
let pracownicy = db.pracownicy.find().toArray();
let produkty = db.produkty.find().toArray();

// Sprawdź czy mamy wszystkie potrzebne dane
if (klienci.length === 0 || pracownicy.length === 0 || produkty.length === 0) {
  print("Brak wymaganych danych w kolekcjach klienci, pracownicy lub produkty!");
} else {
  // Przykładowe zdarzenia
  let dzialania = [
    // Rejestracja klienta
    {
      typ_zdarzenia: "rejestracja",
      data_zdarzenia: new Date(new Date().getTime() - 30*24*60*60*1000), // 30 dni temu
      obiekt_id: klienci[0]._id,
      klient_id: klienci[0]._id,
      dane_zdarzenia: {
        dane_klienta: {
          imie: klienci[0].imie,
          nazwisko: klienci[0].nazwisko,
          email: klienci[0].email,
          telefon: klienci[0].telefon,
          ranga: klienci[0].ranga
        }
      }
    },

    // Wypożyczenie filmu
    {
      typ_zdarzenia: "wypozyczenie",
      data_zdarzenia: new Date(new Date().getTime() - 15*24*60*60*1000), // 15 dni temu
      obiekt_id: produkty[0]._id,
      klient_id: klienci[0]._id,
      pracownik_id: pracownicy[0]._id,
      produkt_id: produkty[0]._id,
      dane_zdarzenia: {
        data_start: new Date(new Date().getTime() - 15*24*60*60*1000),
        data_koniec: new Date(new Date().getTime() - 8*24*60*60*1000)
      }
    },

    // Zwrot filmu
    {
      typ_zdarzenia: "zwrot",
      data_zdarzenia: new Date(new Date().getTime() - 8*24*60*60*1000), // 8 dni temu
      obiekt_id: produkty[0]._id,
      klient_id: klienci[0]._id,
      pracownik_id: pracownicy[0]._id,
      produkt_id: produkty[0]._id,
      dane_zdarzenia: {}
    },

    // Ocena filmu
    {
      typ_zdarzenia: "ocena",
      data_zdarzenia: new Date(new Date().getTime() - 7*24*60*60*1000), // 7 dni temu
      obiekt_id: produkty[0]._id,
      klient_id: klienci[0]._id,
      produkt_id: produkty[0]._id,
      dane_zdarzenia: {
        ocena: 5,
        komentarz: "Świetny film, bardzo polecam!"
      }
    },

    // Rezerwacja audiobooka
    {
      typ_zdarzenia: "rezerwacja",
      data_zdarzenia: new Date(new Date().getTime() - 3*24*60*60*1000), // 3 dni temu
      obiekt_id: produkty[2]._id,
      klient_id: klienci[0]._id,
      pracownik_id: pracownicy[0]._id,
      produkt_id: produkty[2]._id,
      dane_zdarzenia: {
        data_start: new Date(new Date().getTime() - 3*24*60*60*1000),
        data_koniec: new Date(new Date().getTime() + 7*24*60*60*1000)
      }
    },

    // Anulowanie rezerwacji
    {
      typ_zdarzenia: "anulowanie",
      data_zdarzenia: new Date(new Date().getTime() - 1*24*60*60*1000), // wczoraj
      obiekt_id: produkty[2]._id,
      klient_id: klienci[0]._id,
      pracownik_id: pracownicy[0]._id,
      produkt_id: produkty[2]._id,
      dane_zdarzenia: {}
    },

    // Wypożyczenie muzyki
    {
      typ_zdarzenia: "wypozyczenie",
      data_zdarzenia: new Date(), // dzisiaj
      obiekt_id: produkty[1]._id,
      klient_id: klienci[0]._id,
      pracownik_id: pracownicy[0]._id,
      produkt_id: produkty[1]._id,
      dane_zdarzenia: {
        data_start: new Date(),
        data_koniec: new Date(new Date().getTime() + 14*24*60*60*1000)
      }
    },

    // Zmiana statusu wypożyczenia
    {
      typ_zdarzenia: "zmiana_statusu",
      data_zdarzenia: new Date(), // dzisiaj
      obiekt_id: produkty[1]._id,
      klient_id: klienci[0]._id,
      pracownik_id: pracownicy[0]._id,
      produkt_id: produkty[1]._id,
      dane_zdarzenia: {
        nowy_status: "aktywny"
      }
    }
  ];

  // Wstaw dane do kolekcji
  db.dzialania.insertMany(dzialania);

  print("Dodano " + dzialania.length + " przykładowych zdarzeń do kolekcji dzialania.");
}

```

### Wariant 4: Hybrydowy

* `produkty`, `pracownicy`: jak w wariancie 1

```js


let produkty = db.produkty.find().toArray();
let produktyIds = produkty.map(p => p._id);

let pracownicy = db.pracownicy.find().toArray();
let pracownicyIds = pracownicy.map(p => p._id);
print(pracownicyIds);



// Generujemy identyfikatory ocen
const ocenaId1 = new ObjectId();
const ocenaId2 = new ObjectId();
const ocenaId3 = new ObjectId();

// Dodajemy klientów w wariancie hybrydowym
db.klienci_hybrid.insertMany([
  {
    imie: "Jan",
    nazwisko: "Kowalski",
    email: "jan.kowalski@gmail.com",
    telefon: "+48 111 222 333",
    ranga: "standard",
    adres: {
      ulica: "Kwiatowa 5",
      miasto: "Warszawa",
      kod_pocztowy: "00-001"
    },
    zamowienia: [
      {
        produkt_id: produktyIds[0],
        product_name: "Inception",
        typ: "wypozyczenie",
        data_start: new Date(new Date().getTime() - 10*24*60*60*1000), // 10 dni temu
        data_koniec: new Date(new Date().getTime() + 4*24*60*60*1000) // za 4 dni
      }
    ],
    oceny: [
      {
        ocena_id: ocenaId1,
        produkt_id: produktyIds[0],
        ocena: 5
      }
    ]
  },
  {
    imie: "Anna",
    nazwisko: "Nowak",
    email: "anna.nowak@gmail.com",
    telefon: "+48 222 333 444",
    ranga: "premium",
    adres: {
      ulica: "Słoneczna 10",
      miasto: "Kraków",
      kod_pocztowy: "30-001"
    },
    zamowienia: [
      {
        produkt_id: produktyIds[1],
        product_name: "The Dark Side of the Moon",
        typ: "wypozyczenie",
        data_start: new Date(new Date().getTime() - 5*24*60*60*1000), // 5 dni temu
        data_koniec: new Date(new Date().getTime() + 9*24*60*60*1000) // za 9 dni
      },
      {
        produkt_id: produktyIds[2],
        product_name: "Harry Potter i Kamień Filozoficzny",
        typ: "rezerwacja",
        data_start: new Date(new Date().getTime() + 1*24*60*60*1000), // za 1 dzień
        data_koniec: new Date(new Date().getTime() + 15*24*60*60*1000) // za 15 dni
      }
    ],
    oceny: [
      {
        ocena_id: ocenaId2,
        produkt_id: produktyIds[1],
        ocena: 4
      }
    ]
  },
  {
    imie: "Piotr",
    nazwisko: "Wiśniewski",
    email: "piotr.wisniewski@gmail.com",
    telefon: "+48 333 444 555",
    ranga: "vip",
    adres: {
      ulica: "Morska 15",
      miasto: "Gdańsk",
      kod_pocztowy: "80-001"
    },
    zamowienia: [
      {
        produkt_id: produktyIds[0],
        product_name: "Inception",
        typ: "wypozyczenie",
        data_start: new Date(new Date().getTime() - 20*24*60*60*1000), // 20 dni temu
        data_koniec: new Date(new Date().getTime() - 6*24*60*60*1000) // 6 dni temu (zakończone)
      },
      {
        produkt_id: produktyIds[2],
        product_name: "Harry Potter i Kamień Filozoficzny",
        typ: "wypozyczenie",
        data_start: new Date(new Date().getTime() - 3*24*60*60*1000), // 3 dni temu
        data_koniec: new Date(new Date().getTime() + 11*24*60*60*1000) // za 11 dni
      }
    ],
    oceny: [
      {
        ocena_id: ocenaId3,
        produkt_id: produktyIds[0],
        ocena: 5
      }
    ]
  }
]);

// Dodajemy pełne oceny w kolekcji oceny
db.oceny.insertMany([
  {
    _id: ocenaId1,
    klient_id: db.klienci_hybrid.findOne({email: "jan.kowalski@gmail.com"})._id,
    produkt_id: produktyIds[0],
    ocena: 5,
    komentarz: "Świetny film, głęboki i wciągający. Polecam!"
  },
  {
    _id: ocenaId2,
    klient_id: db.klienci_hybrid.findOne({email: "anna.nowak@gmail.com"})._id,
    produkt_id: produktyIds[1],
    ocena: 4,
    komentarz: "Klasyczny album, który doskonale brzmi. Jedyne czego brakuje to trochę więcej dynamiki."
  },
  {
    _id: ocenaId3,
    klient_id: db.klienci_hybrid.findOne({email: "piotr.wisniewski@gmail.com"})._id,
    produkt_id: produktyIds[0],
    ocena: 5,
    komentarz: "Jeden z najlepszych filmów Nolana. Polecam wszystkim miłośnikom dobrego kina."
  }
]);



```





---

## Porównanie zapytań dla różnych wariantów struktur danych

---

## **Wariant 1: Referencyjny**

Dane przechowywane w osobnych kolekcjach: `klienci`, `pracownicy`, `produkty`, `zamowienia`, `oceny`.

### Przykładowe zapytania:

1. **Znalezienie wszystkich aktywnych wypożyczeń filmu o tytule "Film A"**

```js
db.zamowienia.aggregate([
  {
    $match: {
      status: "aktywny"
    }
  },
  {
    $unwind: "$produkty"
  },
  {
    $match: {
      "produkty.typ": "wypozyczenie"
    }
  },
  {
    $lookup: {
      from: "produkty",
      localField: "produkty.produkt_id",
      foreignField: "_id",
      as: "produkt_info"
    }
  },
  {
    $unwind: "$produkt_info"
  },
  {
    $match: {
      "produkt_info.tytul": "Film A"
    }
  },
  {
    $lookup: {
      from: "klienci",
      localField: "klient_id",
      foreignField: "_id",
      as: "klient_info"
    }
  },
  {
    $project: {
      _id: 1,
      "klient_info.imie": 1,
      "klient_info.nazwisko": 1,
      "produkt_info.tytul": 1,
      "produkty.data_start": 1
    }
  }
])
```

Zalety w tym przypadku:  
Możliwość dokładnego filtrowania według wielu parametrów
Łatwe łączenie danych z różnych kolekcji
Aktualizacja danych klienta lub produktu nie wymaga modyfikacji dokumentów zamówień

Wady:
Złożone zapytanie z wieloma etapami agregacji
Większa liczba operacji odczytu z bazy

2. **Aktualizacja stanu magazynowego produktu po wypożyczeniu:**

```js
db.produkty.updateOne(
  { _id: ObjectId("id_produktu") },
  {
    $inc: { 
      ilosc_w_magazynie: -1,
      ilosc_wypozyczona: 1
    }
  }
)
```
 
Prosta operacja aktualizacji
Spójne dane o stanie magazynowym w jednym miejscu


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

1. **Znalezienie wszystkich ocen klienta dla komediowych filmów:**

```js
db.klienci_nested.aggregate([
  {
    $match: {
      "email": "jan.kowalski@gmail.com"
    }
  },
  {
    $unwind: "$oceny"
  },
  {
    $lookup: {
      from: "produkty",
      localField: "oceny.produkt_id",
      foreignField: "_id",
      as: "produkt_info"
    }
  },
  {
    $unwind: "$produkt_info"
  },
  {
    $match: {
      "produkt_info.typ": "film",
      "produkt_info.kategoria": "komedia"
    }
  },
  {
    $project: {
      _id: 0,
      imie: 1,
      nazwisko: 1,
      "produkt_info.tytul": 1,
      "oceny.ocena": 1,
      "oceny.komentarz": 1
    }
  }
])
```

Zalety:  
Wszystkie dane klienta w jednym dokumencie
Mniej operacji łączenia kolekcji

Wady:
Nadal wymaga łączenia z kolekcją produktów
Problem z dużymi dokumentami klientów przy wielu zamówieniach/ocenach

2. ** Dodanie nowego zamówienia dla klienta:**

```js
db.klienci_nested.updateOne(
  { email: "jan.kowalski@gmail.com" },
  {
    $push: {
      zamowienia: {
        produkt_id: ObjectId("id_produktu"),
        typ: "wypozyczenie",
        data_start: new Date(),
        data_koniec: new Date(new Date().setDate(new Date().getDate() + 7))
      }
    }
  }
)
```
Zalety:  
Wszystkie zamówienia klienta od razu zaktualizowane w jednym dokumencie
Szybki dostęp do kompletnej historii klienta

Wady:  
Konieczność osobnej aktualizacji stanu magazynowego
Ryzyko przekroczenia maksymalnego rozmiaru dokumentu BSON (16MB)

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

1. **Znalezienie wszystkich operacji wypożyczenia dla określonego produktu:**

```js
db.dzialania.find(
  {
    typ_zdarzenia: "wypozyczenie",
    produkt_id: ObjectId("id_produktu")
  },
  {
    _id: 1,
    data_zdarzenia: 1,
    klient_id: 1,
    pracownik_id: 1,
    "dane_zdarzenia.data_start": 1,
    "dane_zdarzenia.data_koniec": 1
  }
).sort({ data_zdarzenia: -1 })
```

Zalety:  
Pełna historia wszystkich operacji w systemie
Łatwe śledzenie chronologii zdarzeń
Możliwość rekonstrukcji stanu w dowolnym momencie

Wady:
Wymaga dodatkowych operacji, aby uzyskać aktualne dane encji
Trudniejsza implementacja złożonych zapytań biznesowych

2. **Analiza aktywności pracowników:**

```js
db.dzialania.aggregate([
  {
    $match: {
      pracownik_id: { $exists: true }
    }
  },
  {
    $group: {
      _id: { 
        pracownik_id: "$pracownik_id",
        typ_zdarzenia: "$typ_zdarzenia"
      },
      liczba_operacji: { $sum: 1 }
    }
  },
  {
    $lookup: {
      from: "pracownicy",
      localField: "_id.pracownik_id",
      foreignField: "_id",
      as: "pracownik_info"
    }
  },
  {
    $unwind: "$pracownik_info"
  },
  {
    $project: {
      _id: 0,
      "pracownik_info.imie": 1,
      "pracownik_info.nazwisko": 1,
      typ_zdarzenia: "$_id.typ_zdarzenia",
      liczba_operacji: 1
    }
  },
  {
    $sort: { liczba_operacji: -1 }
  }
])
```

Zalety:  
Doskonałe do analityki i raportowania
Wszystkie zdarzenia chronologicznie w jednym miejscu
Łatwe tworzenie statystyk


3. **Ilość wypożyczeń filmu w maju:**

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

1. **Znajdowanie klientów z aktywnymi wypożyczeniami wybranego produktu**

```js
db.klienci_hybrid.find(
  {
    "zamowienia": {
      $elemMatch: {
        "produkt_id": ObjectId("id_produktu"),
        "typ": "wypozyczenie",
        "data_koniec": { $gt: new Date() }
      }
    }
  },
  {
    _id: 1,
    imie: 1,
    nazwisko: 1,
    email: 1,
    telefon: 1,
    "zamowienia.$": 1
  }
)
```

Zalety:  
Szybkie wyszukiwanie po zagnieżdżonych atrybutach
Brak konieczności łączenia kolekcji przy często używanych danych
Zwracane są tylko pasujące elementy tablicy zamówień

Wady:
Duplikacja niektórych danych (np. nazwy produktów)
Konieczność aktualizacji danych w kilku miejscach

2. **ZWyszukiwanie klientów najczęściej oceniających produkty**

```js
db.klienci_hybrid.aggregate([
  {
    $project: {
      _id: 1,
      imie: 1,
      nazwisko: 1,
      liczba_ocen: { $size: { $ifNull: ["$oceny", []] } }
    }
  },
  {
    $sort: { liczba_ocen: -1 }
  },
  {
    $limit: 10
  }
])
```

Zalety:
Natychmiastowy dostęp do zagnieżdżonych danych
Szybkie operacje bez potrzeby łączenia
Większa czytelność zapytań


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



