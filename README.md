# 👨🏽‍💻 Project: `Portfolio`
[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause) [![Front-end Continuous Integration](https://github.com/zatarain/portfolio/actions/workflows/front-end.yml/badge.svg)](https://github.com/zatarain/portfolio/actions/workflows/front-end.yml) [![Back-end Continuous Integration](https://github.com/zatarain/portfolio/actions/workflows/back-end.yml/badge.svg)](https://github.com/zatarain/portfolio/actions/workflows/back-end.yml) [![codecov](https://codecov.io/gh/zatarain/portfolio/branch/main/graph/badge.svg?token=bufQuVyLCi)](https://codecov.io/gh/zatarain/portfolio)

This project aims to be my personal website and also an interactive portfolio that shows my Curriculum Vitae and comprehensive details about relevant projects I have been working on my academic and professional career in order to have a proof of my knowledge and skills.

## 🗂️ Table of content

* 🔭 [Overview](#📹-overview)
  - ☑️ [Requirements](#-requirements)
  - 🤔 [Assumptions](#-assumptions)
* 📐 [Design](#-design)
  - 🔀 [Workflows](#-workflows)
  - 📊 [Data model](#-data-model)
* 🏗️ [Implementation details](#-implementation-details)
  - 📦 [Dependencies](#-dependencies)
  - 🗄️ [Storage](#-storage)
* ⏯️ [Running](#-running)
  - 🍏 [Development Mode](#-development-mode)
  - 🍎 [Production Mode](#-production-mode)
* ✅ [Testing](#-testing)
  - 🧪 [Manual](#-manual)
  - ♻️ [Automated](#-automated)
  - 💯 [Coverage](#-coverage)
* 📚 [References](#-references)

## 🔭 Overview

This website not only will show general information about myself and my personal life, but also who I am professionally and academically, so I can show to other people what I have done in my career in a professional but more importantly in a fun way. Additionally, it will include a way to contact me and download my curriculum.

The whole project is broken down in three parts: front-end, back-end and infrastructure. This repository will contain the front-end and back-end together, while the infrastructure will be managed using Terraform in my other personal project repository [Lorentz][lorentz].

### ☑️ Requirements
There will be two main mandatory non-functional requirements in the development of this project:

1. The first and most important one is **get fun and enjoy**. As software engineer I want and need to show my passion and enjoyment for the technology. So, this website should speak itself about that.
2. Any hard skill or technology mentioned in my curriculum should be exemplified either on the website or within this project development in some way. This is in order to prove I actually have that hard skill or knowledge about that technology.

Other functional and non-functional requirements are detailed on following subsections.

#### 📃 Show my curriculum
The homepage of the website should show my curriculum vitae including my professional and academic career. The most relevant projects should be highlighted and have a link to provide further information.

#### 🤓 Show my personal life
The homepage should also show details about some of my personal life activities. The website should contain subsections with further information and more activities I do and enjoy.

#### 📧 Contact me by e-mail
The website should provide a way to contact me via e-mail and have some mechanism to control potential spam coming from bots. Neither my email addresses nor my phone numbers should not be shown directly on the website.

#### ⬇️ Download my curriculum
The visitors should have a way to download a printable version of my curriculum vitae as a PDF. The PDF should continue being *user interactive* even if is printed. This means, some of the links should continue working when the user physically print the document (e. g. the document includes QR codes).

#### 📱 Responsive website
All the sections of website should be readable either if the visitor is using a computer or a mobile device like a phone or tablet. This should be tested at least on de default devices listed on chromium-based browsers.

### 🤔 Assumptions

## 📚 References
  * [Ruby On Rails][ror-docs]

---

[lorentz]: https://github.com/zatarain/lorentz
[ror-docs]: https://api.rubyonrails.org
