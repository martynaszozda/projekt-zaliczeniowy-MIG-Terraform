# projekt-zaliczeniowy-MIG-Terraform
Ten projekt Terraform wdraża architekturę **High Availability**, tworząc 2 niezależne, zarządzane grupy instancji (MIG) w 2 regionach Google Cloud Platform (GCP): `us-central1` i `us-east1`.
Każda grupa MIG automatycznie zarządza 2 VM, które są rozproszone na 2 różne strefy zapewniając niezawodność.

<img width="1911" height="422" alt="Zrzut ekranu 2025-11-24 o 18 52 43" src="https://github.com/user-attachments/assets/450c7b46-91f5-40ae-a467-508631ddecab" />
<img width="1660" height="445" alt="Zrzut ekranu 2025-11-24 o 18 55 33" src="https://github.com/user-attachments/assets/d5a7e9c9-1850-4542-9052-807d4c875365" />
<img width="566" height="170" alt="Zrzut ekranu 2025-11-24 o 18 54 13" src="https://github.com/user-attachments/assets/0dc4bb55-971a-4829-95d3-1e6be9f3e38a" />
<img width="458" height="58" alt="Zrzut ekranu 2025-11-24 o 18 53 16" src="https://github.com/user-attachments/assets/912f0587-2f40-4616-938f-4ae732f310a4" />

**Kluczowe funkcjonalności:**
* **Sieć:** Custom VPC z dwoma dedykowanymi podsieciami regionalnymi.
* **Auto-Healing:** Globalny Health Check monitoruje instancje i automatycznie zastępuje te, które uległy awarii.
* **Wdrażanie:** Każda instancja uruchamia serwer Nginx za pomocą skryptu startowego (`nginix-vpc.sh`).
* **Gotowość do Load Balancera:** MIGs są skonfigurowane z Named Ports (`webserver80:80`).

---

## Wymagania Wstępne

1.  **Terraform:** Zainstalowane i skonfigurowane.
2.  **gcloud CLI:** Zainstalowany i skonfigurowany.
3.  **Uwierzytelnienie ADC:** Zalogowane poświadczenia dla Terraform:
    ```bash
    gcloud auth application-default login
    gcloud auth application-default set-quota-project YOUR_PROJECT_ID
    ```
## Strona internetowa działa dla publicznych adresów IP. W tym przypadku, np. tak:
<img width="390" height="445" alt="Zrzut ekranu 2025-11-24 o 18 59 28" src="https://github.com/user-attachments/assets/34ee70d5-a384-47e4-9064-722a230b5118" />

---
## W celu uniknięcia opłat, po uruchomieniu kodu:
terraform destroy -var="project_id=YOUR_PROJECT_ID"
<img width="1178" height="197" alt="Zrzut ekranu 2025-11-24 o 19 33 06" src="https://github.com/user-attachments/assets/e34021c3-04cd-45bb-9723-9f812fd1eec1" />

