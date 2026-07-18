
# 🎯 Агрегаты системы «Будущее 2.0»

Описание ключевых агрегатов в каждом bounded context с указанием границ, инвариантов и идентификаторов.

## 1. Patient Aggregate (Домен пациентов)

**Bounded Context:** Patient Domain  
**Root Entity:** Patient  
**Identifier:** `patient_id` (UUID)

### Границы агрегата:
- **Включает:**
  - Patient (корневая сущность)
  - MedicalHistory (список медицинских записей)
  - ConsentRecord (согласия на обработку данных)
  - ContactInfo (контактная информация)

- **Не включает:**
  - Contract (относится к Contract Domain)
  - Invoice (относится к Billing Domain)

### Инварианты:
1. Пациент должен иметь хотя бы один способ связи (email или телефон)
2. Медицинская история не может содержать записей с будущей датой
3. Согласие на обработку данных должно быть получено до создания медицинской записи
4. Email пациента должен быть уникальным в системе

### Ключевые методы:
```go
type PatientAggregate struct {
    ID          uuid.UUID
    Email       string
    Phone       string
    FullName    string
    BirthDate   time.Time
    Consents    []ConsentRecord
    History     []MedicalRecord
}

func (p *PatientAggregate) Register(consent ConsentRecord) error
func (p *PatientAggregate) AddMedicalRecord(record MedicalRecord) error
func (p *PatientAggregate) UpdateContactInfo(info ContactInfo) error
```

### События:
- `PatientRegistered` — при создании нового пациента
- `ContactInfoUpdated` — при изменении контактов
- `ConsentGiven` — при получении согласия

---

## 2. Contract Aggregate (Домен договоров)

**Bounded Context:** Contract Domain  
**Root Entity:** Contract  
**Identifier:** `contract_id` (UUID)

### Границы агрегата:
- **Включает:**
  - Contract (корневая сущность)
  - TermsAndConditions (условия договора)
  - PricingPlan (тарифный план)
  - SignatureRecord (запись о подписании)

- **Не включает:**
  - Patient (ссылка по ID, но не часть агрегата)
  - Invoice (создается Billing Domain на основе события)

### Инварианты:
1. Договор должен быть связан с существующим пациентом
2. Сумма договора не может быть отрицательной
3. Дата начала не может быть позже даты окончания
4. Договор должен иметь хотя бы один подписанный документ

### Ключевые методы:
```go
type ContractAggregate struct {
    ID          uuid.UUID
    PatientID   uuid.UUID
    StartDate   time.Time
    EndDate     time.Time
    TotalAmount decimal.Decimal
    Status      ContractStatus
    Terms       TermsAndConditions
    Signatures  []SignatureRecord
}

func (c *ContractAggregate) Create(patientID uuid.UUID, terms TermsAndConditions) error
func (c *ContractAggregate) Sign(signature SignatureRecord) error
func (c *ContractAggregate) Terminate(reason string) error
```

### События:
- `ContractCreated` — при создании договора
- `ContractSigned` — при подписании договора
- `ContractTerminated` — при расторжении

---

## 3. Research Aggregate (Домен исследований)

**Bounded Context:** Research Domain  
**Root Entity:** Research  
**Identifier:** `research_id` (UUID)

### Границы агрегата:
- **Включает:**
  - Research (корневая сущность)
  - AIModelConfiguration (конфигурация модели ИИ)
  - DataPipeline (пайплайн обработки данных)
  - ResearchResult (результаты исследования)

- **Не включает:**
  - Patient (ссылка по ID)
  - Contract (ссылка по ID)

### Инварианты:
1. Исследование должно быть связано с существующим договором
2. AI модель должна быть валидирована перед запуском
3. Результаты исследования не могут быть изменены после публикации
4. Максимальное время выполнения исследования — 24 часа

### Ключевые методы:
```go
type ResearchAggregate struct {
    ID              uuid.UUID
    ContractID      uuid.UUID
    PatientID       uuid.UUID
    AIConfig        AIModelConfiguration
    Status          ResearchStatus
    Results         []ResearchResult
    StartedAt       time.Time
    CompletedAt     *time.Time
}

func (r *ResearchAggregate) Start(config AIModelConfiguration) error
func (r *ResearchAggregate) Complete(results []ResearchResult) error
func (r *ResearchAggregate) Cancel(reason string) error
```

### События:
- `ResearchStarted` — при запуске исследования
- `ResearchCompleted` — при завершении исследования
- `ResearchFailed` — при ошибке выполнения

---

## 4. Invoice Aggregate (Домен биллинга)

**Bounded Context:** Billing Domain  
**Root Entity:** Invoice  
**Identifier:** `invoice_id` (UUID)

### Границы агрегата:
- **Включает:**
  - Invoice (корневая сущность)
  - InvoiceLine (строки счета)
  - PaymentRecord (записи об оплатах)
  - TaxCalculation (расчет налогов)

- **Не включает:**
  - Contract (ссылка по ID)
  - PaymentGateway (внешняя система)

### Инварианты:
1. Сумма всех строк счета должна равняться общей сумме
2. Счет не может быть оплачен больше, чем его общая сумма
3. Дата оплаты не может быть раньше даты выставления счета
4. Налоговая ставка должна соответствовать юрисдикции пациента

### Ключевые методы:
```go
type InvoiceAggregate struct {
    ID          uuid.UUID
    ContractID  uuid.UUID
    PatientID   uuid.UUID
    Lines       []InvoiceLine
    TotalAmount decimal.Decimal
    TaxAmount   decimal.Decimal
    Status      InvoiceStatus
    Payments    []PaymentRecord
}

func (i *InvoiceAggregate) Generate(contract ContractSummary) error
func (i *InvoiceAggregate) RecordPayment(payment PaymentRecord) error
func (i *InvoiceAggregate) Cancel(reason string) error
```

### События:
- `InvoiceGenerated` — при создании счета
- `PaymentReceived` — при получении оплаты
- `InvoiceOverdue` — при просрочке оплаты

---

## 5. Notification Aggregate (Домен уведомлений)

**Bounded Context:** Notification Domain  
**Root Entity:** Notification  
**Identifier:** `notification_id` (UUID)

### Границы агрегата:
- **Включает:**
  - Notification (корневая сущность)
  - Recipient (получатель)
  - Template (шаблон уведомления)
  - DeliveryStatus (статус доставки)

- **Не включает:**
  - EmailService (внешняя система)
  - SMSService (внешняя система)

### Инварианты:
1. Уведомление должно иметь хотя бы один способ доставки
2. Шаблон уведомления должен существовать до отправки
3. Максимальное количество попыток доставки — 3
4. Персональные данные не должны логироваться

### Ключевые методы:
```go
type NotificationAggregate struct {
    ID              uuid.UUID
    RecipientID     uuid.UUID
    TemplateID      string
    Channels        []NotificationChannel
    Status          DeliveryStatus
    Attempts        int
    CreatedAt       time.Time
    DeliveredAt     *time.Time
}

func (n *NotificationAggregate) Send(channels []NotificationChannel) error
func (n *NotificationAggregate) MarkDelivered() error
func (n *NotificationAggregate) Retry() error
```

### События:
- `NotificationSent` — при отправке уведомления
- `NotificationDelivered` — при успешной доставке
- `NotificationFailed` — при ошибке доставки

---

## 6. Report Aggregate (Домен аналитики)

**Bounded Context:** Analytics Domain  
**Root Entity:** Report  
**Identifier:** `report_id` (UUID)

### Границы агрегата:
- **Включает:**
  - Report (корневая сущность)
  - DataSource (источники данных)
  - Visualization (визуализации)
  - Filter (фильтры)

- **Не включает:**
  - ML Pipeline (внешняя система)
  - Dashboard (отдельный агрегат)

### Инварианты:
1. Отчет должен иметь хотя бы один источник данных
2. Период отчета не может превышать 1 год
3. Данные для отчета должны быть агрегированы до генерации
4. Доступ к отчету должен быть ограничен по ролям

### Ключевые методы:
```go
type ReportAggregate struct {
    ID          uuid.UUID
    Title       string
    DataSources []DataSource
    Filters     []Filter
    Visualizations []Visualization
    GeneratedAt time.Time
    AccessRoles []string
}

func (r *ReportAggregate) Generate(sources []DataSource) error
func (r *ReportAggregate) AddFilter(filter Filter) error
func (r *ReportAggregate) ShareWithRoles(roles []string) error
```

### События:
- `ReportGenerated` — при создании отчета
- `ReportShared` — при предоставлении доступа
- `ReportExpired` — при истечении срока действия

---

##  Сводная таблица агрегатов

| Агрегат | Домен | Идентификатор | Ключевые события |
|---------|-------|---------------|------------------|
| Patient | Patient Domain | patient_id | PatientRegistered, ContactInfoUpdated |
| Contract | Contract Domain | contract_id | ContractCreated, ContractSigned |
| Research | Research Domain | research_id | ResearchStarted, ResearchCompleted |
| Invoice | Billing Domain | invoice_id | InvoiceGenerated, PaymentReceived |
| Notification | Notification Domain | notification_id | NotificationSent, NotificationDelivered |
| Report | Analytics Domain | report_id | ReportGenerated, ReportShared |

---

## 🔗 Связи между агрегатами

Агрегаты взаимодействуют **только через доменные события**, обеспечивая слабую связность:

```
PatientRegistered → ContractCreated → InvoiceGenerated → PaymentReceived
                                              ↓
                                        ResearchCompleted → ReportGenerated
```

Каждый агрегат **не знает** о существовании других агрегатов — он только публикует события и реагирует на них.