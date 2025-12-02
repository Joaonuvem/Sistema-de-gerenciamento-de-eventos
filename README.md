# Sistema-de-gerenciamento-de-eventos
Trata-se de um trabalho de banco de dados, onde uma parte dele é desenvolver um banco de dados em SQL de um sistema de gerenciamento de eventos.

# -> Sistema de Gerenciamento de Eventos (PostgreSQL)

Este repositório contém o projeto de Banco de Dados Relacional desenvolvido para gerenciar o ciclo de vida de eventos acadêmicos e corporativos. O sistema controla locais, categorias, participantes e inscrições, garantindo integridade de dados e automação de regras de negócio.

## -> Funcionalidades Principais

O banco de dados foi modelado para atender aos seguintes requisitos:

- **Gestão de Eventos:** Cadastro de eventos vinculados a locais (com capacidade limitada) e categorias.
- **Controle de Inscrições:** Sistema de registro N:N (Muitos-para-Muitos) com restrição de unicidade (uma pessoa não pode se inscrever 2x no mesmo evento).
- **Relatórios Automáticos (Views):**
  - Lista de presença detalhada.
  - Relatório estatístico de inscritos por evento.
- **Lógica de Negócio (Stored Functions):**
  - Cálculo dinâmico de vagas restantes (`fn_vagas_restantes`).
  - Geração de resumos textuais de participantes.
- **Automação e Segurança (Triggers):**
  - **Auditoria:** Registro automático de log quando uma inscrição é cancelada.
  - **Validação:** Bloqueio de novas inscrições se o status do evento não for 'Agendado'.

## -> Tecnologias Utilizadas

- **SGBD:** PostgreSQL (v14+)
- **Ferramenta de Gerenciamento:** pgAdmin 4
- **Linguagem:** SQL (DDL, DML, DQL)

## -> Estrutura do Projeto

O projeto está organizado seguindo as boas práticas de normalização (até a 3FN):

| Arquivo | Descrição |
| :--- | :--- |
| `script_completo.sql` | Script mestre contendo todo o projeto (Drops, Creates, Inserts, Triggers, Testes). |
| `creates.sql` | Estrutura das tabelas (`CREATE TABLE`) e relacionamentos. |
| `inserts.sql` | Carga inicial de dados fictícios para testes. |
| `views.sql` | Criação das tabelas virtuais para relatórios. |
| `functions_triggers.sql` | Implementação da lógica avançada (Funções e Gatilhos). |

## -> Modelo de Dados (Schema)

As principais tabelas do sistema são:

1.  **Categorias:** Tipos de eventos (Workshop, Palestra, etc.).
2.  **Locais:** Salas e auditórios com definição de capacidade máxima.
3.  **Participantes:** Cadastro de usuários com validação de CPF e Email únicos.
4.  **Eventos:** Entidade central que herda características de Local e Categoria.
5.  **Inscricoes:** Tabela associativa que liga Participantes a Eventos.
6.  **Logs_Sistema:** Tabela de auditoria populada automaticamente por triggers.

## -> Como Rodar este Projeto

### Pré-requisitos
- Ter o **PostgreSQL** instalado.
- Ter o **pgAdmin 4** (ou outro cliente SQL como DBeaver/Datagrip).

### Passo a Passo
1.  Clone este repositório:
    ```bash
    git clone [https://github.com/SEU-USUARIO/sistema-gestao-eventos.git](https://github.com/SEU-USUARIO/sistema-gestao-eventos.git)
    ```
2.  Abra o pgAdmin 4 e crie um novo banco de dados chamado `gestao_eventos`.
3.  Abra a **Query Tool** (Ferramenta de Consulta) neste novo banco.
4.  Abra o arquivo `script_completo.sql` (ou copie e cole seu conteúdo).
5.  Execute o script (F5).
    * *Nota:* O script possui uma rotina de `DROP IF EXISTS CASCADE` no início, permitindo que seja reexecutado múltiplas vezes para testes limpos.

## -> Plano de Testes

O script final inclui uma seção de validação que prova o funcionamento dos gatilhos:
1.  Verifica o saldo de vagas antes de uma ação.
2.  Executa a remoção de um participante.
3.  Comprova a geração de log na tabela de auditoria.
4.  Comprova o aumento no número de vagas disponíveis.

---
**Autor:** João Carlo De Sousa Gurgel Rocha
**Disciplina:** Banco de Dados
**Professor:**
