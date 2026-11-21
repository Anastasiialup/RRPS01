Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Drawing

$outputDocx = "c:\Users\nasta\Webstorm projects\reengineering\lab1\zvit_lab1.docx"
Remove-Item $outputDocx -ErrorAction SilentlyContinue

$tempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path "$tempDir\_rels" -Force | Out-Null
New-Item -ItemType Directory -Path "$tempDir\word\_rels" -Force | Out-Null
New-Item -ItemType Directory -Path "$tempDir\word\media" -Force | Out-Null

# Copy images to media
Copy-Item "c:\Users\nasta\Webstorm projects\reengineering\lab1\git_clone_screenshot.png" "$tempDir\word\media\image1.png"
Copy-Item "c:\Users\nasta\Webstorm projects\reengineering\lab1\structure_screenshot.png" "$tempDir\word\media\image2.png"
Copy-Item "c:\Users\nasta\Webstorm projects\reengineering\lab1\class_diagram.png" "$tempDir\word\media\image3.png"
Copy-Item "c:\Users\nasta\Webstorm projects\reengineering\lab1\component_diagram.png" "$tempDir\word\media\image4.png"

# 1. [Content_Types].xml
$contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + "`r`n" +
'<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">' + "`r`n" +
'  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>' + "`r`n" +
'  <Default Extension="xml" ContentType="application/xml"/>' + "`r`n" +
'  <Default Extension="png" ContentType="image/png"/>' + "`r`n" +
'  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>' + "`r`n" +
'  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>' + "`r`n" +
'</Types>'
[System.IO.File]::WriteAllText("$tempDir\[Content_Types].xml", $contentTypes, [System.Text.Encoding]::UTF8)

# 2. _rels/.rels
$rels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + "`r`n" +
'<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' + "`r`n" +
'  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>' + "`r`n" +
'</Relationships>'
[System.IO.File]::WriteAllText("$tempDir\_rels\.rels", $rels, [System.Text.Encoding]::UTF8)

# 3. word/_rels/document.xml.rels
$docRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + "`r`n" +
'<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' + "`r`n" +
'  <Relationship Id="rIdStyles" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>' + "`r`n" +
'  <Relationship Id="rIdImg1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image1.png"/>' + "`r`n" +
'  <Relationship Id="rIdImg2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image2.png"/>' + "`r`n" +
'  <Relationship Id="rIdImg3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image3.png"/>' + "`r`n" +
'  <Relationship Id="rIdImg4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image4.png"/>' + "`r`n" +
'</Relationships>'
[System.IO.File]::WriteAllText("$tempDir\word\_rels\document.xml.rels", $docRels, [System.Text.Encoding]::UTF8)

# 4. word/styles.xml
$stylesXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' + "`r`n" +
'<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">' + "`r`n" +
'  <w:docDefaults>' + "`r`n" +
'    <w:rPrDefault>' + "`r`n" +
'      <w:rPr>' + "`r`n" +
'        <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>' + "`r`n" +
'        <w:sz w:val="28"/>' + "`r`n" +
'        <w:szCs w:val="28"/>' + "`r`n" +
'        <w:lang w:val="uk-UA"/>' + "`r`n" +
'      </w:rPr>' + "`r`n" +
'    </w:rPrDefault>' + "`r`n" +
'    <w:pPrDefault>' + "`r`n" +
'      <w:pPr>' + "`r`n" +
'        <w:spacing w:line="360" w:lineRule="auto" w:after="120"/>' + "`r`n" +
'      </w:pPr>' + "`r`n" +
'    </w:pPrDefault>' + "`r`n" +
'  </w:docDefaults>' + "`r`n" +
'</w:styles>'
[System.IO.File]::WriteAllText("$tempDir\word\styles.xml", $stylesXml, [System.Text.Encoding]::UTF8)

# Helper XML builder
$sb = New-Object System.Text.StringBuilder

function Escape-Xml([string]$text) {
    if ([string]::IsNullOrEmpty($text)) { return "" }
    return $text.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace('"', "&quot;").Replace("'", "&apos;")
}

function Add-P([string]$text, [string]$align = "both", [bool]$bold = $false, [bool]$italic = $false, [int]$sz = 28, [int]$spaceBefore = 0, [int]$spaceAfter = 120, [bool]$indent = $true) {
    $pPr = "<w:pPr>"
    if ($align -ne "both") { $pPr += "<w:jc w:val=`"$align`"/>" } else { $pPr += "<w:jc w:val=`"both`"/>" }
    if ($indent) { $pPr += "<w:ind w:firstLine=`"709`"/>" } else { $pPr += "<w:ind w:firstLine=`"0`"/>" }
    $pPr += "<w:spacing w:before=`"$spaceBefore`" w:after=`"$spaceAfter`" w:line=`"360`" w:lineRule=`"auto`"/>"
    $pPr += "</w:pPr>"

    $rPr = "<w:rPr>"
    if ($bold) { $rPr += "<w:b/>" }
    if ($italic) { $rPr += "<w:i/>" }
    $rPr += "<w:sz w:val=`"$sz`"/><w:szCs w:val=`"$sz`"/>"
    $rPr += "</w:rPr>"

    $esc = Escape-Xml $text
    $xml = "<w:p>$pPr<w:r>$rPr<w:t xml:space=`"preserve`">$esc</w:t></w:r></w:p>"
    [void]$sb.AppendLine($xml)
}

function Add-Heading([string]$text, [int]$level = 1) {
    $sz = if ($level -eq 1) { 32 } else { 28 }
    $before = if ($level -eq 1) { 280 } else { 200 }
    Add-P $text -align "left" -bold $true -italic $false -sz $sz -spaceBefore $before -spaceAfter 120 -indent $false
}

function Add-Center([string]$text, [bool]$bold = $false, [int]$sz = 28, [int]$after = 100) {
    Add-P $text -align "center" -bold $bold -sz $sz -spaceAfter $after -indent $false
}

function Add-Caption([string]$text) {
    Add-P $text -align "center" -bold $false -italic $true -sz 24 -spaceBefore 60 -spaceAfter 180 -indent $false
}

function Add-Image([string]$relId, [long]$cx, [long]$cy) {
    $xml = @"
<w:p>
  <w:pPr>
    <w:jc w:val="center"/>
    <w:spacing w:before="120" w:after="80"/>
    <w:ind w:firstLine="0"/>
  </w:pPr>
  <w:r>
    <w:drawing>
      <wp:inline distT="0" distB="0" distL="0" distR="0">
        <wp:extent cx="$cx" cy="$cy"/>
        <wp:docPr id="1" name="Figure"/>
        <a:graphic>
          <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
            <pic:pic>
              <pic:nvPicPr>
                <pic:cNvPr id="1" name="Figure"/>
                <pic:cNvPicPr/>
              </pic:nvPicPr>
              <pic:blipFill>
                <a:blip r:embed="$relId"/>
                <a:stretch><a:fillRect/></a:stretch>
              </pic:blipFill>
              <pic:spPr>
                <a:xfrm>
                  <a:off x="0" y="0"/>
                  <a:ext cx="$cx" cy="$cy"/>
                </a:xfrm>
                <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
              </pic:spPr>
            </pic:pic>
          </a:graphicData>
        </a:graphic>
      </wp:inline>
    </w:drawing>
  </w:r>
</w:p>
"@
    [void]$sb.AppendLine($xml)
}

function Add-Code([string[]]$lines) {
    foreach ($line in $lines) {
        $esc = Escape-Xml $line
        $xml = @"
<w:p>
  <w:pPr>
    <w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>
    <w:ind w:firstLine="0" w:left="400"/>
    <w:shd w:val="clear" w:color="auto" w:fill="F4F4F6"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:rFonts w:ascii="Consolas" w:hAnsi="Consolas" w:cs="Consolas"/>
      <w:sz w:val="20"/>
      <w:szCs w:val="20"/>
      <w:color w:val="1E1E2E"/>
    </w:rPr>
    <w:t xml:space="preserve">$esc</w:t>
  </w:r>
</w:p>
"@
        [void]$sb.AppendLine($xml)
    }
    Add-P "" -indent $false -spaceAfter 120
}

function Add-PageBreak {
    [void]$sb.AppendLine("<w:p><w:r><w:br w:type=`"page`"/></w:r></w:p>")
}

# START DOCUMENT BODY
[void]$sb.AppendLine('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
[void]$sb.AppendLine('<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">')
[void]$sb.AppendLine('<w:body>')

# ТИТУЛЬНА ЧАСТИНА
Add-Center "НАЦІОНАЛЬНИЙ ТЕХНІЧНИЙ УНІВЕРСИТЕТ УКРАЇНИ" -bold $true -sz 26 -after 40
Add-Center "«КИЇВСЬКИЙ ПОЛІТЕХНІЧНИЙ ІНСТИТУТ ІМЕНІ ІГОРЯ СІКОРСЬКОГО»" -bold $true -sz 26 -after 40
Add-Center "Факультет інформатики та обчислювальної техніки" -bold $false -sz 26 -after 40
Add-Center "Кафедра інженерії програмного забезпечення" -bold $false -sz 26 -after 280

Add-Center "ЗВІТ" -bold $true -sz 32 -after 60
Add-Center "з лабораторної роботи №1" -bold $true -sz 28 -after 60
Add-Center "з дисципліни «Реінжиніринг програмного забезпечення»" -bold $false -sz 28 -after 60
Add-Center "Тема: Аналіз структури програмної системи та зворотне проєктування" -bold $true -sz 28 -after 400

Add-P "Виконала:" -align "right" -sz 26 -indent $false -spaceAfter 40
Add-P "студентка групи ІПЗм-26-1" -align "right" -sz 26 -indent $false -spaceAfter 40
Add-P "Лупашина Анастасія" -align "right" -bold $true -sz 26 -indent $false -spaceAfter 40
Add-P "Перевірив: викладач кафедри" -align "right" -sz 26 -indent $false -spaceAfter 600

Add-Center "Київ — 2026" -sz 26 -after 0
Add-PageBreak

# МЕТА ТА ЗАВДАННЯ
Add-Heading "Мета роботи"
Add-P "Навчитися виконувати початковий аналіз програмного проєкту з відкритим вихідним кодом, виявляти його архітектурну структуру, виділяти функціональні компоненти та будувати UML-діаграми класів і компонентів для зворотного проєктування (reverse engineering)."

Add-Heading "Література"
Add-P "Bass L., Clements P., Kazman R. Software Architecture in Practice (SEI Series in Software Engineering). Print2print, 2022. 442 с. ISBN 978-0-13-688609-9."

Add-Heading "1. Вибір проєкту з відкритим вихідним кодом та клонування"
Add-P "Для виконання лабораторної роботи було обрано відкритий веб-проєкт react-shopping-cart (автор — Jefferson Ribeiro), доступний на платформі GitHub за посиланням: https://github.com/jeffersonRibeiro/react-shopping-cart."
Add-P "Проєкт являє собою клієнтський SPA-додаток електронної комерції (інтернет-магазин одягу) на базі React та TypeScript. Кодова база каталогу src/ налічує 52 файли вихідного коду загальним обсягом 1432 рядки без урахування тестів (2065 рядків разом із юніт-тестами), що повністю задовольняє обмеження лабораторної роботи (не більше 5000 рядків коду)."
Add-P "Клонування репозиторію та перевірку кількості рядків вихідного коду наведено на рис. 1."

Add-Image "rIdImg1" 5500000 2300000
Add-Caption "Рис. 1 — Клонування репозиторію та перевірка обсягу вихідного коду"

Add-Heading "2. Запуск системи, призначення програми та основні можливості"
Add-P "Призначення програми: react-shopping-cart моделює користувацький інтерфейс інтернет-магазину. Застосунок забезпечує перегляд каталогу товарів, фільтрацію одягу за розмірною сіткою, керування плаваючим кошиком (додавання, зміна кількості, видалення товарів), миттєвий перерахунок загальної вартості замовлення та розрахунок розстрочки, а також імітацію оформлення покупки (checkout)."
Add-P "Стек технологій:"
Add-P "• Мова програмування: TypeScript / JavaScript (ES6+);" -indent $false
Add-P "• Бібліотека інтерфейсу: React 18 (використання функціональних компонентів і хуків);" -indent $false
Add-P "• Керування станом (State Management): React Context API + Custom Hooks;" -indent $false
Add-P "• Стилізація: styled-components (підхід CSS-in-JS із підтримкою тем);" -indent $false
Add-P "• Мережева взаємодія: Axios для HTTP-запитів до Firebase Realtime Database (production) або локального JSON-файлу (development);" -indent $false
Add-P "• Тестування: Jest, React Testing Library." -indent $false

Add-Heading "3. Структура каталогів вихідного коду"
Add-P "Вихідний код проєкту організовано за модульним принципом, де чітко розмежовано компоненти представлення, глобальний стан, доменні моделі, сервіси отримання даних та утиліти. Структуру каталогу src/ наведено на рис. 2."

Add-Image "rIdImg2" 5500000 4010000
Add-Caption "Рис. 2 — Структура каталогів вихідного коду проєкту react-shopping-cart"

Add-P "Призначення основних каталогів:"
Add-P "• src/components/ — містить модулі інтерфейсу користувача (UI Presentation Components). Кожен візуальний блок (App, Cart, Filter, Products, Loader) винесено в окрему підпапку з власним файлом стилів style.ts та юніт-тестами;" -indent $false
Add-P "• src/contexts/ — реалізує шар управління станом на базі React Context API. Містить два контексти: cart-context (стан кошика, відкриття/закриття, список товарів) та products-context (каталог товарів, статус завантаження, активні фільтри);" -indent $false
Add-P "• src/models/ — централізований модуль опису доменних типів та інтерфейсів TypeScript (IProduct, ICartProduct, ICartTotal);" -indent $false
Add-P "• src/services/ — шар доступу до даних (Data Access Layer). Файл products.ts інкапсулює виконання HTTP-запитів через Axios до Firebase REST API або завантаження локального файлу products.json;" -indent $false
Add-P "• src/commons/ — спільні глобальні стилі (GlobalStyle), кольорова палітра теми (theme.ts) та базовий UI-компонент Checkbox;" -indent $false
Add-P "• src/utils/ — допоміжні утиліти загального призначення (зокрема утиліта formatPrice для форматування грошових сум);" -indent $false
Add-P "• src/static/ — статичні ресурси: зображення товарів у форматі webp та резервний JSON-файл із переліком товарів." -indent $false

Add-PageBreak

Add-Heading "4. Список основних класів, інтерфейсів і модулів"
Add-P "Нижче наведено перелік основних сутностей системи, їхню роль в архітектурі та фрагменти вихідного коду."

Add-P "1. Інтерфейси доменної моделі (src/models/index.ts):" -bold $true
Add-P "• IProduct — описує структуру одиниці товару в каталозі (ідентифікатор, назва, ціна, доступні розміри, кількість платежів розстрочки, валюта тощо). Виступає базовим контрактом даних для всіх шарів додатку."
Add-P "• ICartProduct — інтерфейс товару в кошику, що наслідує IProduct та доповнює його полем quantity (кількість обраних одиниць товару)."
Add-P "• ICartTotal — описує об'єкт фінансового підсумку кошика (загальна кількість одиниць, максимальна кількість місяців розстрочки, сумарна ціна замовлення та валюта)."

$codeModels = @(
    "// src/models/index.ts",
    "export interface IProduct {",
    "  id: number;",
    "  sku: number;",
    "  title: string;",
    "  description: string;",
    "  availableSizes: string[];",
    "  style: string;",
    "  price: number;",
    "  installments: number;",
    "  currencyId: string;",
    "  currencyFormat: string;",
    "  isFreeShipping: boolean;",
    "}",
    "",
    "export interface ICartProduct extends IProduct {",
    "  quantity: number;",
    "}",
    "",
    "export interface ICartTotal {",
    "  productQuantity: number;",
    "  installments: number;",
    "  totalPrice: number;",
    "  currencyId: string;",
    "  currencyFormat: string;",
    "}"
)
Add-Code $codeModels
Add-Caption "Лістинг 1 — Інтерфейси доменної моделі (models/index.ts)"

Add-P "2. Шар управління станом (src/contexts/):" -bold $true
Add-P "• CartContextProvider — провайдер контексту кошика, що інкапсулює стан списку обраних товарів, прапорець відкритості модальної панелі та підсумковий об'єкт total."
Add-P "• useCart — фасадний хук, що об'єднує функціонал хуків useCartProducts та useCartTotal і надає єдиний спрощений інтерфейс для UI-компонентів кошика."
Add-P "• useCartProducts — реалізує бізнес-логіку додавання товару, видалення, безпечної зміни кількості (+/-). При кожній операції вручну викликає перерахунок загальної вартості."
Add-P "• useCartTotal — виконує агрегацію суми замовлення, загальної кількості товарів та розрахунок розстрочки за допомогою методу reduce."
Add-P "• ProductsContextProvider та useProducts — забезпечують отримання переліку товарів через сервіс products.ts, збереження статусу isFetching та фільтрацію каталогу за розмірами."

$codeCartHook = @(
    "// src/contexts/cart-context/useCartProducts.ts (фрагмент)",
    "const useCartProducts = () => {",
    "  const { products, setProducts } = useCartContext();",
    "  const { updateCartTotal } = useCartTotal();",
    "",
    "  const addProduct = (newProduct: ICartProduct) => {",
    "    let updatedProducts;",
    "    const isProductAlreadyInCart = products.some(p => newProduct.id === p.id);",
    "    if (isProductAlreadyInCart) {",
    "      updatedProducts = products.map(p => updateQuantitySafely(p, newProduct, newProduct.quantity));",
    "    } else {",
    "      updatedProducts = [...products, newProduct];",
    "    }",
    "    setProducts(updatedProducts);",
    "    updateCartTotal(updatedProducts); // жорстка зв'язаність між хуками",
    "  };",
    "  return { products, addProduct, removeProduct, increaseProductQuantity, decreaseProductQuantity };",
    "};"
)
Add-Code $codeCartHook
Add-Caption "Лістинг 2 — Хук керування товарами в кошику (useCartProducts.ts)"

Add-P "3. Сервісний рівень доступу до даних (src/services/products.ts):" -bold $true
Add-P "• products.ts — модуль отримання даних. У продакшн-режимі здійснює асинхронний GET-запит через бібліотеку Axios до бази даних Firebase, а у середовищі розробки імпортує статичний JSON-файл."

$codeService = @(
    "// src/services/products.ts",
    "import axios from 'axios';",
    "const isProduction = process.env.NODE_ENV === 'production';",
    "",
    "export const getProducts = async () => {",
    "  let response;",
    "  if (isProduction) {",
    "    response = await axios.get('https://react-shopping-cart-67954.firebaseio.com/products.json');",
    "  } else {",
    "    response = require('static/json/products.json');",
    "  }",
    "  const { products } = response.data || [];",
    "  return products;",
    "};"
)
Add-Code $codeService
Add-Caption "Лістинг 3 — Сервіс отримання товарів (products.ts)"

Add-P "4. Презентаційний рівень (UI-компоненти):" -bold $true
Add-P "• App — кореневий контейнер, що монтує двоколонкову розмітку (фільтри ліворуч, каталог праворуч, кошик поверх) та ініціює початковий запит товарів при завантаженні сторінки."
Add-P "• Products та Product — відображають сітку товарів інтернет-магазину та окрему картку товару з фотографією, цінником, бейджем безкоштовної доставки та кнопкою додавання в кошик."
Add-P "• Filter — панель фільтрів за розмірною сіткою (XS, S, M, ML, L, XL, XXL). При зміні стану чекбокса викликає оновлення списку товарів."
Add-P "• Cart, CartProducts, CartProduct — ієрархія компонентів бічної панелі кошика. Відображають перелік доданих товарів, елементи зміни кількості, загальну суму та кнопку Checkout."

Add-PageBreak

Add-Heading "5. UML-діаграма класів та інтерфейсів"
Add-P "На основі зворотного проєктування вихідного коду побудовано UML-діаграму класів та інтерфейсів (рис. 3). Діаграма відображає ключові інтерфейси моделей даних, кастомні хуки, сервіси та UI-компоненти з їхніми полями й методами."
Add-P "Основні типи зв'язків між елементами:"
Add-P "• Наслідування (Generalization/Inheritance): інтерфейс ICartProduct розширює IProduct полем quantity;" -indent $false
Add-P "• Реалізація (Realization): провайдери CartContextProvider та ProductsContextProvider реалізують інтерфейси контекстів ICartContext та IProductsContext;" -indent $false
Add-P "• Композиція (Composition): App містить компоненти Filter, Products та Cart; компонент Cart володіє CartProducts;" -indent $false
Add-P "• Агрегація (Aggregation): Products агрегує колекцію карток Product; CartProducts агрегує множину елементів CartProduct;" -indent $false
Add-P "• Залежність та асоціація (Dependency/Association): хук useCart використовує useCartProducts та useCartTotal; компоненти Product та Cart викликають методи хука useCart." -indent $false

Add-Image "rIdImg3" 3200000 6860000
Add-Caption "Рис. 3 — UML-діаграма класів та інтерфейсів програмної системи"

Add-PageBreak

Add-Heading "6. UML-діаграма компонентів"
Add-P "UML-діаграма компонентів (рис. 4) демонструє дворівневу архітектуру клієнтського застосунку з розбиттям на окремі логічні шари (Presentation, State Management, Domain, Data Access, Remote Backend) та зв'язки між ними."

Add-Image "rIdImg4" 3300000 6730000
Add-Caption "Рис. 4 — UML-діаграма компонентів та рівнів архітектури"

Add-P "Взаємодія між шарами відбувається за такою схемою:"
Add-P "1. Presentation Layer (App, Filter, Products, Cart) відповідає виключно за рендеринг інтерфейсу користувача та перехоплення подій (кліки, введення);" -indent $false
Add-P "2. State Management Layer (контексти та хуки) інкапсулює стан додатку та правила його мутації. UI-компоненти не змінюють стан напряму, а викликають методи хуків;" -indent $false
Add-P "3. Domain Layer (TypeScript інтерфейси) визначає єдиний контракт типів для всіх підсистем;" -indent $false
Add-P "4. Data Access Layer (сервіс products.ts) ізолює роботу з мережею від логіки стану та компонентів. Залежно від оточення звертається до хмарного сховища Firebase або локального JSON-файлу." -indent $false

Add-Heading "7. Аналіз проблемних місць програмної системи"
Add-P "У ході детального зворотного проєктування коду та аналізу побудованих UML-діаграм виявлено такі архітектурні недоліки та проблеми:"

Add-P "7.1. Надмірні залежності (Tight Coupling) та проблема похідного стану (Derived State)" -bold $true
Add-P "Сутність total (загальна вартість, кількість товарів, умови розстрочки) зберігається як окремий незалежний стан useState у CartContextProvider. Внаслідок цього хук useCartProducts змушений при кожній операції додавання, видалення чи зміни кількості товару вручну викликати функцію updateCartTotal(updatedProducts)."
Add-P "Це створює жорстку залежність між двома хуками та несе ризик розсинхронізації: якщо інший розробник викличе setProducts без виклику updateCartTotal, дані на екрані розійдуться. Правильним архітектурним рішенням є використання похідного стану (derived state) через хук useMemo, де total обчислюється автоматично на основі масиву products без ручного збереження в стані."

Add-P "7.2. Нераціональна повторна фільтрація через мережевий запит" -bold $true
Add-P "У файлі src/contexts/products-context/useProducts.tsx метод filterProducts при кожній зміні прапорця фільтра знову ініціює запит getProducts() до бекенду, після чого фільтрує отриманий результат. Оскільки каталог товарів невеликий і вже був завантажений при старті, повторний мережевий виклик є надлишковим. Доцільно зберегти первинний масив allProducts у пам'яті й виконувати фільтрацію локально."

Add-P "7.3. Витік бізнес-правил у презентаційний рівень (Leaky Abstraction)" -bold $true
Add-P "Кнопка зменшення кількості товару в CartProduct.tsx блокується властивістю disabled={quantity === 1 ? true : false}. Проте сам метод decreaseProductQuantity у хуку useCartProducts.ts не містить перевірки на мінімальну кількість і просто віднімає 1. Бізнес-правило («кількість товару в кошику не може бути меншою за 1») контролюється виключно HTML-кнопкою, а не доменною логікою. Програмний виклик методу може призвести до некоректного стану (0 або від'ємна кількість товару)."

Add-P "7.4. «Божественний» компонент Cart (порушення принципу Single Responsibility)" -bold $true
Add-P "Компонент Cart.tsx одночасно відповідає за анімацію висувної панелі, рендеринг списку товарів, математичний розрахунок щомісячного платежу розстрочки (total.totalPrice / total.installments), логіку оформлення замовлення та виклик системного діалогу alert(). Розрахунок розстрочки слід винести в утиліти, а сповіщення оформити через окремий UI-компонент модального вікна."

Add-P "7.5. Відсутність обробки помилок мережі (Missing Error Handling)" -bold $true
Add-P "У сервісі products.ts та хуку useProducts.tsx відсутні блоки try/catch або обробники помилок .catch(). У разі відсутності зв'язку з інтернетом або помилки сервера 500 стан isFetching назавжди залишається true, інтерфейс зависає на індикаторі Loader без повідомлення користувачеві."

Add-P "7.6. Відсутність персистентності стану (No State Persistence)" -bold $true
Add-P "Стан кошика зберігається лише в оперативній пам'яті браузера. При випадковому перезавантаженні сторінки або переході користувача всі додані товари безповоротно втрачаються. Необхідно додати синхронізацію з localStorage."

Add-Heading "Висновки"
Add-P "Сильні сторони архітектури:"
Add-P "1. Чітке розмежування відповідальностей за шарами (компоненти, контексти стану, моделі, сервіси);" -indent $false
Add-P "2. Строга типізація даних через TypeScript-інтерфейси, що унеможливлює помилки несумісності структури даних;" -indent $false
Add-P "3. Ізоляція стилів за допомогою styled-components, що запобігає конфліктам глобальних CSS-класів;" -indent $false
Add-P "4. Висока тестова придатність завдяки винесенню логіки в ізольовані кастомні хуки." -indent $false

Add-P "Слабкі сторони архітектури:"
Add-P "1. Жорстка зв'язаність між хуками кошика через ручне оновлення похідного стану total;" -indent $false
Add-P "2. Зайві HTTP-запити до сервера при повторному застосуванні фільтрів розміру;" -indent $false
Add-P "3. Витік валідації мінімальної кількості товару з бізнес-шару в шар інтерфейсу користувача;" -indent $false
Add-P "4. Відсутність обробки мережевих винятків та відсутність збереження стану в локальному сховищі браузера." -indent $false

Add-P "У ході виконання роботи було успішно виконано зворотне проєктування реального програмного проєкту, виділено його ключові структурні компоненти, побудовано UML-діаграми класів та компонентів, виявлено архітектурні недоліки та запропоновано рекомендації щодо їх рефакторингу."

[void]$sb.AppendLine('</w:body>')
[void]$sb.AppendLine('</w:document>')

[System.IO.File]::WriteAllText("$tempDir\word\document.xml", $sb.ToString(), [System.Text.Encoding]::UTF8)

# Pack into DOCX
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $outputDocx)
Remove-Item -Recurse -Force $tempDir

Get-Item $outputDocx | Select-Object Name, Length
