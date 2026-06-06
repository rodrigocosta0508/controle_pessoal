# Controle Pessoal - Documentation

**Version:** 1.0  
**Language:** Portuguese (pt-BR)  
**Last Updated:** 2026-06-04

---

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Application Architecture](#application-architecture)
4. [Database Schema](#database-schema)
5. [Pages and User Interface](#pages-and-user-interface)
6. [API Integration](#api-integration)
7. [Technical Stack](#technical-stack)
8. [User Guide](#user-guide)

---

## Overview

**Controle Pessoal** is a web-based personal finance management system designed to track and manage personal credit and debit operations. The application allows users to:

- Register financial operations (income and expenses)
- Organize operations by categories and subcategories
- Track billing cycles for different financial operators
- Generate consolidated reports for multiple users
- View detailed analytics and summaries

The system is multi-user capable, supporting separate expense tracking for different individuals (e.g., Rodrigo and Cris).

---

## Features

### Core Features

1. **Operation Management**
   - Create new credit or debit operations
   - Query and edit existing operations
   - Support for installment payments with tracking
   - Link operations to billing cycles

2. **Category Management**
   - Create and organize expense categories
   - Support for subcategories (hierarchical structure)
   - Edit and update category names
   - List all available categories

3. **Billing & Invoicing**
   - Track billing cycles with defined periods
   - Link operations to specific invoices
   - View invoice details and statements

4. **Financial Consolidation**
   - Generate consolidated reports by user (Rodrigo, Cris)
   - Group and summarize expenses by category
   - View consolidated data for shared expenses (Ambos)

5. **Financial Analytics**
   - Dashboard for financial overview
   - Statement details (extratos) showing totals by billing cycle
   - Categorized expense summaries

---

## Application Architecture

### Technology Stack

- **Frontend:** HTML5, CSS3, Bootstrap 5.3.3, JavaScript, Font Awesome 6.5.0
- **Backend:** Oracle Database, PL/SQL Packages, Netlify Functions
- **Hosting:** Netlify (API proxy function)
- **Language:** Primarily Portuguese (pt-BR)

### Project Structure

```
controle_pessoal/
├── index.html                  # Main dashboard/homepage
├── operacoes.html             # Create operations
├── consultar_operacoes.html   # Query/edit operations
├── categorias.html            # Category management
├── extratos.html              # Invoice details
├── consolidado_cris.html      # Cris's consolidated view
├── consolidado_rodrigo.html   # Rodrigo's consolidated view
├── dashboard.html             # Financial dashboard (commented)
├── dashboard.js               # Dashboard JavaScript utilities
├── OBJECTS/                   # Database objects
│   ├── TABLES/               # Table definitions
│   ├── VIEWS/                # SQL views
│   └── PACKAGES/             # PL/SQL packages
└── netlify/
    └── functions/
        └── api-proxy.js      # API proxy function
```

---

## Database Schema

### ER Diagram (Entity Relationship Diagram)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DATABASE RELATIONSHIPS                            │
└─────────────────────────────────────────────────────────────────────────┘

                                ┌──────────────────┐
                                │   USUARIOS       │
                                ├──────────────────┤
                                │ PK ID_USUARIO    │
                                │    NM_USUARIO    │
                                └────────┬─────────┘
                                         │
                                         │ 1:N
                                         │
                    ┌────────────────────┴─────────────────────┐
                    │                                          │
                    ▼                                          │
    ┌────────────────────────────┐                            │
    │     OPERACOES              │                            │
    ├────────────────────────────┤                            │
    │ PK  ID_OPERACAO            │                            │
    │     ID_OPERACAO_PAR        │◄──┐ (Self-reference)      │
    │ FK  ID_FATURA              │   │ (Installments)        │
    │ FK  ID_OPERADORA           │   │                       │
    │ FK  ID_USUARIO ────────────┼───┘                       │
    │ FK  ID_CATEGORIA           │                            │
    │     TIPO_OPERACAO          │                            │
    │     DT_OPERACAO            │                            │
    │     VL_OPERACAO            │                            │
    │     PARCELA_ATUAL          │                            │
    │     PARCELA_TOTAL          │                            │
    │     TP_RESPONSAVEL (R/C/A) │                            │
    └────┬──────────┬────────┬───┘                            │
         │          │        │                                 │
         │ 1:N      │ 1:N    │ 1:N                             │
         │          │        │                                 │
    ┌────▼──┐  ┌────▼──┐   ┌─▼──────────────────┐            │
    │CATEGO-│  │FATURAS│   │  OPERADORAS        │            │
    │RIAS   │  │       │   ├────────────────────┤            │
    ├───────┤  ├───────┤   │ PK ID_OPERADORA    │            │
    │PK ID_ │  │PK ID_ │   │    NM_OPERADORA    │            │
    │CATEG. │  │FATURAS│   └────────────────────┘            │
    │NM_    │  │FK ID_ │                                      │
    │CATEG. │  │OPERAD.◄──────┐                              │
    │NM_SUB │  │DESC_  │      │                              │
    │CATEG. │  │FATURA │      │ (Composite FK)              │
    │       │  │INI_   │      │                              │
    │       │  │FATURA │      │                              │
    │       │  │FIM_   │      │                              │
    │       │  │FATURA │      │                              │
    │       │  │VENCIM.│      │                              │
    └───────┘  └───────┘      │                              │
                               │                              │
                               └──────────────────────────────┘

```

### Relationship Summary

| From Table | To Table | Relationship | Type |
|-----------|----------|--------------|------|
| OPERACOES | CATEGORIAS | 1:N | Many operations per category |
| OPERACOES | FATURAS | 1:N | Many operations per invoice |
| OPERACOES | USUARIOS | 1:N | Many operations per user |
| OPERACOES | OPERADORAS | 1:N | Many operations per operator |
| FATURAS | OPERADORAS | 1:N | Many invoices per operator |
| OPERACOES | OPERACOES | 1:N | Self-join for installments |

### Key Constraints

**Primary Keys (PK):**
- OPERACOES: ID_OPERACAO
- CATEGORIAS: ID_CATEGORIA
- FATURAS: (ID_FATURA, ID_OPERADORA) - Composite key
- USUARIOS: ID_USUARIO
- OPERADORAS: ID_OPERADORA

**Foreign Keys (FK):**
- OPERACOES.ID_CATEGORIA → CATEGORIAS.ID_CATEGORIA
- OPERACOES.ID_FATURA, ID_OPERADORA → FATURAS (ID_FATURA, ID_OPERADORA)
- OPERACOES.ID_USUARIO → USUARIOS.ID_USUARIO
- FATURAS.ID_OPERADORA → OPERADORAS.ID_OPERADORA

**Indexes for Performance:**
- IDX_OPERACOES_CAT: Speeds up category-based queries
- IDX_OPERACOES_FAT: Speeds up invoice-based queries
- IDX_OPERACOES_USU: Speeds up user-based queries

---

### Tables

#### RODRIGO.OPERACOES (Operations)
Primary table for financial operations tracking.

| Column | Type | Description |
|--------|------|-------------|
| ID_OPERACAO | NUMBER | Unique operation identifier (PK) |
| ID_OPERACAO_PAR | NUMBER | Parent operation ID (for installments) |
| ID_FATURA | NUMBER | Associated invoice ID (FK) |
| ID_OPERADORA | NUMBER | Associated operator ID (FK) |
| ID_USUARIO | NUMBER | User who created the operation (FK) |
| ID_CATEGORIA | NUMBER | Category of the operation (FK, NOT NULL) |
| TIPO_OPERACAO | VARCHAR2(30) | Type: CRÉDITO or DÉBITO (NOT NULL) |
| DT_OPERACAO | DATE | Operation date (NOT NULL) |
| VL_OPERACAO | FLOAT | Operation value (NOT NULL) |
| PARCELA_ATUAL | NUMBER | Current installment number |
| PARCELA_TOTAL | NUMBER | Total number of installments |
| TP_RESPONSAVEL | CHAR(1) | Responsibility: R=Rodrigo, C=Cris, A=Ambos (NOT NULL) |

**Indexes:**
- PK_OPERACOES (ID_OPERACAO)
- IDX_OPERACOES_USU (ID_USUARIO)
- IDX_OPERACOES_CAT (ID_CATEGORIA)
- IDX_OPERACOES_FAT (ID_FATURA)

**Constraints:**
- TP_RESPONSAVEL must be R, C, or A
- Foreign keys: CATEGORIAS, FATURAS, USUARIOS

---

#### RODRIGO.CATEGORIAS (Categories)
Stores expense categories and subcategories.

| Column | Type | Description |
|--------|------|-------------|
| ID_CATEGORIA | NUMBER | Unique category identifier (PK) |
| NM_CATEGORIA | VARCHAR2(30) | Category name (NOT NULL) |
| NM_SUB_CATEGORIA | VARCHAR2(30) | Subcategory name (NOT NULL) |

**Example Data Structure:**
- Alimentação > Restaurante
- Transporte > Uber
- Saúde > Farmácia

---

#### RODRIGO.FATURAS (Invoices)
Tracks billing cycles for financial operators.

| Column | Type | Description |
|--------|------|-------------|
| ID_FATURA | NUMBER | Invoice ID (PK) |
| ID_OPERADORA | NUMBER | Operator ID (PK, FK) |
| DESC_FATURA | VARCHAR2(7) | Invoice description (e.g., "202506") |
| INI_FATURA | DATE | Invoice period start (NOT NULL) |
| FIM_FATURA | DATE | Invoice period end (NOT NULL) |
| VENCIMENTO | DATE | Due date (NOT NULL) |

---

#### RODRIGO.USUARIOS (Users)
User list for the system.

| Column | Type | Description |
|--------|------|-------------|
| ID_USUARIO | NUMBER | User ID (PK) |
| NM_USUARIO | VARCHAR2(30) | User name (NOT NULL) |

**Current Users:**
- Rodrigo
- Cris

---

#### RODRIGO.OPERADORAS (Operators)
Financial operators/credit card issuers.

| Column | Type | Description |
|--------|------|-------------|
| ID_OPERADORA | NUMBER | Operator ID (PK) |
| NM_OPERADORA | VARCHAR2(10) | Operator name (NOT NULL) |

---

### Database Views

#### DESC_OPERACOES_V
General operations summary view with descriptions.

#### DESC_OPERACOES_RODRIGO_V
Filtered operations view for Rodrigo's expenses.

#### DESC_OPERACOES_CRIS_V
Filtered operations view for Cris's expenses.

#### DESC_OPERACOES_PARC_V
Installment operations view for partial/installment tracking.

---

### PL/SQL Packages

#### PKG_OPERACOES
Package for operation-related database procedures:
- Create/Insert operations
- Update operations
- Query operations with filters
- Calculate summaries

#### PKG_CATEGORIAS
Package for category management:
- Create categories
- Update category information
- Delete/Archive categories
- List categories

#### PKG_FATURAS
Package for invoice management:
- Create billing cycles
- Update invoice information
- Query invoices by period

#### PKG_USUARIOS
Package for user management:
- Create users
- List users

#### PKG_OPERADORAS
Package for operator management:
- Create operators
- List operators

---

## Pages and User Interface

### 1. Index/Dashboard (`index.html`)
**Purpose:** Main navigation hub for the application

**Features:**
- Welcome message: "Controle Pessoal - Gerenciamento de Operações Financeiras"
- Grid-based menu layout with 6 main sections
- Responsive design (mobile-friendly)
- Styled with Bootstrap 5.3.3

**Navigation Options:**
- Consultar Operações (Query Operations)
- Criar Operação (Create Operation)
- Gerenciar Categorias (Manage Categories)
- Detalhes de Faturas (Invoice Details)
- Consolidado CRIS (Cris's Consolidated View)
- Consolidado RODRIGO (Rodrigo's Consolidated View)

---

### 2. Create Operation (`operacoes.html`)
**Purpose:** Add new credit or debit transactions

**Features:**
- Form-based operation entry
- Input fields for:
  - Operation date
  - Operation type (Credit/Debit)
  - Operation value
  - Category selection
  - Subcategory selection
  - User assignment
  - Responsible party (Rodrigo, Cris, or Both)
  - Invoice association
  - Installment options (if applicable)
- Form validation
- Loading spinner during submission

---

### 3. Query Operations (`consultar_operacoes.html`)
**Purpose:** Search, view, and edit existing operations

**Features:**
- Search/filter operations by:
  - Date range
  - Category
  - User
  - Operation type
  - Responsible party
- Display results in table format
- Edit individual operations
- Delete operations
- View operation details

---

### 4. Category Management (`categorias.html`)
**Purpose:** Manage expense categories and subcategories

**Features (Tabbed Interface):**
1. **Create Tab**
   - Form to add new category
   - Input: Category name, Subcategory name
   - Submit button with loading state

2. **List Tab**
   - Table showing all categories
   - Columns: Category, Subcategory
   - Auto-loads on tab selection

3. **Edit Tab**
   - Dropdown selectors for Category and Subcategory
   - Edit form for changing category names
   - Update functionality with validation

---

### 5. Invoice Details (`extratos.html`)
**Purpose:** View detailed billing information and statements

**Features:**
- Display operations organized by:
  - Billing cycle
  - Category
  - Subcategory
- Calculate totals by:
  - Invoice period
  - Category
  - Responsible party
- Filter by operator and date range
- Export capabilities (if available)

---

### 6. Consolidated Cris (`consolidado_cris.html`)
**Purpose:** Cris's personalized financial summary

**Features:**
- Consolidated view of all Cris's operations
- Grouped by:
  - Category
  - Subcategory
  - Time period
- Summary calculations:
  - Total expenses
  - Monthly averages
  - Category breakdowns
- Filter options by date range
- Charts and visual representations

---

### 7. Consolidated Rodrigo (`consolidado_rodrigo.html`)
**Purpose:** Rodrigo's personalized financial summary

**Features:**
- Consolidated view of all Rodrigo's operations
- Grouped by:
  - Category
  - Subcategory
  - Time period
- Summary calculations:
  - Total expenses
  - Monthly averages
  - Last 12 months average
  - Category breakdowns
- Filter options by date range
- Charts and visual representations

---

### 8. Dashboard (`dashboard.html`)
**Purpose:** Financial analytics dashboard (currently commented/disabled)

**Features (when enabled):**
- Chart visualizations of expenses
- Trend analysis
- Spending comparisons
- Multi-user comparison charts
- Interactive filters

---

## API Integration

### Netlify Functions

**Location:** `/netlify/functions/api-proxy.js`

**Purpose:** Acts as a proxy between the frontend and the Oracle Database

**Responsibilities:**
- Route API requests to appropriate database packages
- Handle authentication/authorization
- Execute PL/SQL package procedures
- Return JSON responses to frontend
- Error handling and response formatting

**API Endpoints (inferred from code structure):**
- `/api/operacoes` - Operations management
- `/api/categorias` - Category management
- `/api/faturas` - Invoice management
- `/api/usuarios` - User management
- `/api/operadoras` - Operator management

---

## Technical Stack

### Frontend
- **HTML5:** Semantic markup
- **CSS3:** Bootstrap 5.3.3 framework, custom styling
- **JavaScript:** Vanilla JS (no framework), async/await for API calls
- **Icons:** Font Awesome 6.5.0
- **Responsive Design:** Mobile-first, Bootstrap grid system

### Backend
- **Database:** Oracle Database
- **Language:** PL/SQL (stored procedures, packages)
- **Functions:** Netlify Functions (Node.js runtime)
- **Hosting:** Netlify

### Version Control
- **Git:** Repository management
- **Main Branch:** Main

---

## User Guide

### Getting Started

1. **Navigate to the Application**
   - Open `index.html` in your browser
   - You'll see the main dashboard with navigation options

2. **First-Time Setup**
   - Create categories through "Gerenciar Categorias"
   - Add users through the database (if needed)
   - Configure operators for billing cycles

### Common Workflows

#### Adding a New Expense

1. Click "Criar Operação" (Create Operation)
2. Fill in the form:
   - Date of purchase
   - Type: DÉBITO (Debit) for expenses
   - Amount spent
   - Category and Subcategory
   - Assign to yourself or mark as shared
3. Click "Criar Operação"
4. If paying in installments, mark the installment details

#### Adding Income

1. Click "Criar Operação" (Create Operation)
2. Fill in the form:
   - Date received
   - Type: CRÉDITO (Credit) for income
   - Amount received
   - Category (e.g., Salário, Bônus)
3. Submit the form

#### Viewing Your Expenses

1. **Quick Summary:** Click "Consolidado RODRIGO" or "Consolidado CRIS"
2. **Detailed View:** Click "Detalhes de Faturas" to see breakdown by billing cycle
3. **Search Operations:** Click "Consultar Operações" to find specific transactions

#### Managing Categories

1. Go to "Gerenciar Categorias"
2. Use the "Criar" (Create) tab to add new categories
3. Use the "Listar" (List) tab to view all categories
4. Use the "Alterar" (Edit) tab to modify existing categories

#### Editing Operations

1. Click "Consultar Operações"
2. Search for the operation you want to edit
3. Click the edit button/icon
4. Modify the details and save

### Data Entry Tips

- **Dates:** Use consistent date format (DD/MM/YYYY or YYYY-MM-DD)
- **Categories:** Keep category names consistent for better reporting
- **Installments:** Always specify total installments and current installment number
- **Responsible Party:** Mark "Ambos" (Both) for shared expenses

### Reporting

- **Monthly Summary:** View "Consolidado" pages for monthly breakdown
- **Category Analysis:** Check category totals in consolidated views
- **Invoice Details:** Use "Detalhes de Faturas" for billing cycle analysis
- **User Comparison:** Both "Consolidado RODRIGO" and "Consolidado CRIS" allow side-by-side analysis

---

## Troubleshooting

### Common Issues

1. **Form Validation Errors**
   - Ensure all required fields are filled
   - Check date format matches system requirements
   - Verify numeric fields contain valid numbers

2. **API Errors**
   - Check browser console for error messages
   - Verify database connection is active
   - Ensure Netlify functions are deployed

3. **Missing Data**
   - Verify categories exist before creating operations
   - Check that users are registered in the system
   - Ensure billing cycles are created for the period

4. **Performance Issues**
   - Clear browser cache
   - Limit date range in queries
   - Close unnecessary browser tabs

---

## Future Enhancements

- Enable the Financial Dashboard with interactive charts
- Add export to CSV/Excel functionality
- Implement recurring operations/subscriptions
- Add budget tracking and alerts
- Mobile app native version
- Multi-language support
- Advanced reporting and analytics

---

## Support & Maintenance

For issues or feature requests, please check:
- The repository's issue tracker
- Database logs for errors
- Browser console for client-side errors
- Netlify function logs for backend errors

---

**End of Documentation**
