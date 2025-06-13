# 🎓 OpenCertify

**OpenCertify** é uma plataforma open source para aplicação de provas, exames e certificações técnicas ou institucionais. O projeto visa oferecer uma solução flexível, segura e extensível para instituições, avaliadores e candidatos, com foco em transparência, automação e validação confiável de resultados.

---

## 📌 Objetivos do Projeto

- Disponibilizar uma plataforma para aplicação de provas e certificações online
- Oferecer mecanismos de criação e gerenciamento de provas por avaliadores ou instituições
- Permitir que candidatos realizem provas com correção automática e/ou manual
- Gerar certificados e insígnias digitais com autenticação por hash e timestamp
- Integrar meios de pagamento para aquisição de provas e emissão de certificados
- Ser totalmente open source, auditável e personalizável por qualquer organização

---

## 🧱 Tecnologias Utilizadas

### Front-end
- HTML5, CSS3
- [React.js](https://react.dev/) + [TailwindCSS](https://tailwindcss.com/)
- jsPDF (geração de PDFs)

### Back-end
- [Node.js](https://nodejs.org/)
- [PostgreSQL](https://www.postgresql.org/) (base de dados relacional)
- Redis (controle de sessões e cache de provas em tempo real)
- SHA-256 + Timestamp server-side (verificação de autenticidade de certificados)

### Autenticação
- [Keycloak](https://www.keycloak.org/) com OAuth2 (RBAC: Aluno, Avaliador/Instituição, Admin)

### Pagamentos
- Integração com [Pagar.me](https://pagar.me/) e [Abacatepay](https://abacatepay.com.br/)

### Infraestrutura
- [Docker](https://www.docker.com/) (ambiente de desenvolvimento e produção)
- [Nginx](https://nginx.org/) + [Let's Encrypt](https://letsencrypt.org/) (proxy reverso e HTTPS automático)
- GitHub Actions (CI/CD)
- [Grafana](https://grafana.com/) + [Zabbix](https://www.zabbix.com/) (monitoramento)
- [Graylog](https://graylog.org/) (logs e auditoria)

---

## 🧑‍💻 Perfis de Usuário

### Aluno / Avaliado
- Inscrição na plataforma
- Acesso ao catálogo de provas
- Solicitação ou compra de acesso às provas
- Execução de provas (com controle de tempo)
- Visualização de certificados e insígnias conquistados
- Histórico de provas e pagamentos
- Pagamento via gateway (Pagar.me ou Abacatepay)

### Avaliador / Instituição
- Criação e publicação de provas e exames
- Configuração de banco de questões reutilizáveis
- Definição de métricas de aprovação
- Aprovação manual de inscrições (opcional)
- Criação e personalização de certificados, insígnias e certificações

---

## 📄 Licença

Este projeto está licenciado sob a **GNU Affero General Public License v3.0 (AGPLv3)**.

Você pode:
- Usar, estudar e modificar este código livremente
- Distribuir cópias com ou sem modificações
- Utilizar o sistema em ambientes comerciais

**Atenção:** qualquer uso público (inclusive via web) exige a disponibilização do código-fonte correspondente, conforme os termos da AGPLv3.

> Leia o arquivo [LICENSE](./LICENSE) para mais detalhes.

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Consulte o [CONTRIBUTING.md](./CONTRIBUTING.md) para diretrizes sobre como colaborar com este projeto.

---

## 🗺️ Roadmap

- [ ] Autenticação com Keycloak
- [ ] Catálogo público de provas
- [ ] Criação de provas por avaliadores
- [ ] Execução de provas com timer e correção automática
- [ ] Geração de certificados com jsPDF
- [ ] Integração com gateways de pagamento
- [ ] Interface do painel do aluno
- [ ] Painel do avaliador/instituição
- [ ] Página pública para verificação de certificados

---

## 📬 Contato

Projeto criado e mantido por [Arthur (Network & Cybersecurity Analyst)](https://www.linkedin.com/in/arthur-raupp-coelho/).  
Contribuições da comunidade são incentivadas — sinta-se livre para abrir uma issue ou pull request.

---

