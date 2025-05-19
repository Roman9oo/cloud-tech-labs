# Cloud Tech Labs — Doman 1: DynamoDB + Lambda + Terraform

## Опис

Цей проєкт реалізує **повністю автоматизовану інфраструктуру AWS** для управління курсами та авторами, згідно з методичкою лабораторної роботи **Домен 1**.

Використані сервіси:

- AWS DynamoDB (NoSQL база даних)
- AWS Lambda (серверлес функції)
- Terraform (інфраструктура як код)
- AWS S3 + DynamoDB для Terraform backend

---

## 📂 Структура проєкту

```bash
my-terraform-project/
├── lambda/                    # JS-код для Lambda
│   ├── get-all-authors.js
│   ├── get-all-courses.js
│   ├── get-course.js
│   ├── save-course.js
│   ├── update-course.js
│   └── delete-course.js
├── terraform/                 # Кожна Lambda в окремому tf-файлі
│   ├── get-all-courses.tf
│   ├── get-course.tf
│   ├── save-course.tf
│   ├── update-course.tf
│   └── delete-course.tf
├── lambda.tf                 # Перший варіант (get-all-authors)
├── main.tf                   # Основні ресурси
├── backend.tf                # Terraform backend (S3 + DynamoDB lock)
├── variables.tf              # Змінні (якщо треба)
├── outputs.tf                # Виводи ресурсів
├── .gitignore
└── README.md
