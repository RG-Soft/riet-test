//Обновление на бух. корп. 3.0.38.43
//ВНИМАНИЕ, подразуемевается, что галки "формировать проводки, ИспользоватьДокументРасчетовКакСчетФактуру", а так же 
//выбор документа расчетов и документа оплаты не требуется для лоджелки. Эти действия запрещены в конфигураторе и не правились от ошибок
//<=


////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ
//

&НаСервере
Процедура УстановитьУсловноеОформление()

	НастройкиУсловногоОформления = Новый Структура();

	УсловноеОформление.Элементы.Очистить();

	// Условное оформление, связанное с видимостью, устанавливаем сразу для всех колонок.
	УстановитьУсловноеОформлениеШапкаИВидимость();

	// Условное оформление для полей, расположенных на страницах

	ОбновитьУсловноеОформление(ЭтотОбъект);

КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ОбновитьУсловноеОформление(Форма)

	Элементы = Форма.Элементы;

	Если НЕ Форма.НастройкиУсловногоОформления.Свойство("ТоварыУслугиПроинициализировано")
		И Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.ГруппаТоварыУслуги Тогда

		Форма.УстановитьУсловноеОформлениеТоварыУслуги();

	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьУсловноеОформлениеШапкаИВидимость()

	// КорректируемыйПериод

	ЭлементУО = УсловноеОформление.Элементы.Добавить();

	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "КорректируемыйПериод");

	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ЭлементУО.Отбор,
		"Объект.ЗаписьДополнительногоЛиста", ВидСравненияКомпоновкиДанных.Равно, Ложь);

	ЭлементУО.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Ложь);


	// РасчетныйДокумент

	ЭлементУО = УсловноеОформление.Элементы.Добавить();

	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "РасчетныйДокумент");

	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ЭлементУО.Отбор,
		"Объект.ИспользоватьДокументРасчетовКакСчетФактуру", ВидСравненияКомпоновкиДанных.Равно, Ложь);

	ЭлементУО.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Ложь);


	// ТоварыУслугиВидЦенности, ТоварыУслугиСобытие

	ЭлементУО = УсловноеОформление.Элементы.Добавить();

	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТоварыУслугиВидЦенности");
	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТоварыУслугиСобытие");

	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ЭлементУО.Отбор,
		"Объект.ПрямаяЗаписьВКнигу", ВидСравненияКомпоновкиДанных.Равно, Ложь);

	ЭлементУО.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);


	// ТоварыУслугиСчетУчетаНДСПоРеализации, ТоварыУслугиСубконто

	ЭлементУО = УсловноеОформление.Элементы.Добавить();

	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТоварыУслугиСчетУчетаНДСПоРеализации");
	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТоварыУслугиСубконто");

	ГруппаОтбора1 = КомпоновкаДанныхКлиентСервер.ДобавитьГруппуОтбора(ЭлементУО.Отбор.Элементы, ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИли);

		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ГруппаОтбора1,
			"Объект.ФормироватьПроводки", ВидСравненияКомпоновкиДанных.Равно, Ложь);

		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ГруппаОтбора1,
			"Объект.ПрямаяЗаписьВКнигу", ВидСравненияКомпоновкиДанных.Равно, Ложь);

	ЭлементУО.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);


	// ТоварыУслугиСторнирующаяЗаписьДопЛиста

	ЭлементУО = УсловноеОформление.Элементы.Добавить();

	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТоварыУслугиСторнирующаяЗаписьДопЛиста");

	ГруппаОтбора1 = КомпоновкаДанныхКлиентСервер.ДобавитьГруппуОтбора(ЭлементУО.Отбор.Элементы, ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИли);

		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ГруппаОтбора1,
			"Объект.ПрямаяЗаписьВКнигу", ВидСравненияКомпоновкиДанных.Равно, Ложь);

		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ГруппаОтбора1,
			"Объект.ЗаписьДополнительногоЛиста", ВидСравненияКомпоновкиДанных.Равно, Ложь);

		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ГруппаОтбора1,
			"Объект.ФормироватьСторнирующиеЗаписиДопЛистовВручную", ВидСравненияКомпоновкиДанных.Равно, Ложь);

	ЭлементУО.Оформление.УстановитьЗначениеПараметра("Видимость", Ложь);

КонецПроцедуры

&НаСервере
Процедура УстановитьУсловноеОформлениеТоварыУслуги() Экспорт

	НастройкиУсловногоОформления.Вставить("ТоварыУслугиПроинициализировано", Истина);


	// Поля не требуются при прямой записи в книгу.

	ЭлементУО = УсловноеОформление.Элементы.Добавить();

	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТоварыУслугиСчетУчета");
	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТоварыУслугиСчетДоходов");
	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТоварыУслугиНоменклатура");
	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТоварыУслугиСчетУчетаНДСПоРеализации");

	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ЭлементУО.Отбор,
		"Объект.ПрямаяЗаписьВКнигу", ВидСравненияКомпоновкиДанных.Равно, Истина);

	ЭлементУО.Оформление.УстановитьЗначениеПараметра("ОтметкаНезаполненного", Ложь);


	// ТоварыУслугиСуммаНДС

	ЭлементУО = УсловноеОформление.Элементы.Добавить();

	КомпоновкаДанныхКлиентСервер.ДобавитьОформляемоеПоле(ЭлементУО.Поля, "ТоварыУслугиСуммаНДС");

	ГруппаОтбора1 = КомпоновкаДанныхКлиентСервер.ДобавитьГруппуОтбора(ЭлементУО.Отбор.Элементы, ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИли);

		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ГруппаОтбора1,
			"Объект.ТоварыИУслуги.СтавкаНДС", ВидСравненияКомпоновкиДанных.Равно, Перечисления.СтавкиНДС.НДС0);

		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(ГруппаОтбора1,
			"Объект.ТоварыИУслуги.СтавкаНДС", ВидСравненияКомпоновкиДанных.Равно, Перечисления.СтавкиНДС.БезНДС);

	ЭлементУО.Оформление.УстановитьЗначениеПараметра("ТолькоПросмотр", Истина);

КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ЗаполнитьРеквизитыПроСчетФактуру(Форма, РеквизитыСФ = Неопределено)
	
	ИмяРеквизитаСсылка = ?(
		Форма.Объект.ИспользоватьДокументРасчетовКакСчетФактуру, 
		"РасчетныйДокумент", 
		"Ссылка");
		
	УчетНДСКлиентСервер.ЗаполнитьРеквизитыФормыПроСчетФактуруВыданный(
		Форма,
		РеквизитыСФ,
		Истина,
		, // СтруктураОтбора
		, // ИмяРеквизитаСчетФактура
		ИмяРеквизитаСсылка);
		
КонецПроцедуры

&НаСервереБезКонтекста
Функция НайтиПодчиненныйСчетФактуруВыданныйНаРеализацию(ДокументОснование)

	Возврат УчетНДСПереопределяемый.НайтиПодчиненныйСчетФактуруВыданныйНаРеализацию(ДокументОснование);

КонецФункции

&НаКлиенте
Процедура ОбработатьИзмененияПоКнопкеЦеныИВалюты(ВалютаДокумента = Неопределено)

	// 1. Формируем структуру параметров для заполнения формы "Цены и Валюта".
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("Организация",          Объект.Организация);
	СтруктураПараметров.Вставить("ДатаДокумента",        Объект.Дата);
	СтруктураПараметров.Вставить("ВалютаДокумента",      ?(ВалютаДокумента <> Неопределено, ВалютаДокумента, Объект.ВалютаДокумента));
	СтруктураПараметров.Вставить("Курс",                 Объект.КурсВзаиморасчетов);
	СтруктураПараметров.Вставить("Кратность",            Объект.КратностьВзаиморасчетов);
	СтруктураПараметров.Вставить("СуммаВключаетНДС",     Объект.СуммаВключаетНДС);
	СтруктураПараметров.Вставить("Контрагент",           Объект.Контрагент);
	СтруктураПараметров.Вставить("Договор",              Объект.ДоговорКонтрагента);
	СтруктураПараметров.Вставить("ТипЦен",               Объект.ТипЦен);

	// 2. Открвыаем форму "Цены и Валюта".
	ДополнительныеПараметры = Новый Структура;
	
	Если ИспользоватьТипыЦенНоменклатуры
		ИЛИ (ЕстьВалютныйУчет И Объект.ВалютаДокумента <> ВалютаРегламентированногоУчета)
		ИЛИ РасчетыВУЕ Тогда 
		
		ОткрыватьИзМеню = Ложь;
		
	Иначе
		ОткрыватьИзМеню = Истина;
		ДополнительныеПараметры.Вставить("СтруктураПараметровКоманды", СтруктураПараметров);
	КонецЕсли;
	
	ОповещениеОЗакрытии = Новый ОписаниеОповещения("ОбработатьИзмененияПоКнопкеЦеныИВалютыЗавершение", ЭтотОбъект, ДополнительныеПараметры);
	
	Если ОткрыватьИзМеню Тогда
		
		СписокКоманд = Новый СписокЗначений;
		
		СписокКоманд.Добавить(ПредопределенноеЗначение("Перечисление.ВариантыРасчетаНДС.НДССверху"));
		СписокКоманд.Добавить(ПредопределенноеЗначение("Перечисление.ВариантыРасчетаНДС.НДСВСумме"));
		
		ПоказатьВыборИзМеню(ОповещениеОЗакрытии, СписокКоманд, Элементы.ЦеныИВалюта);
	Иначе
		ОткрытьФорму("ОбщаяФорма.ФормаЦеныИВалютаТиповая", СтруктураПараметров,,,,,ОповещениеОЗакрытии);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьИзмененияПоКнопкеЦеныИВалютыЗавершение(РезультатЗакрытия, ДополнительныеПараметры) Экспорт
	
	Если ДополнительныеПараметры.Свойство("СтруктураПараметровКоманды") Тогда
		
		СтруктураЦеныИВалюта = ДополнительныеПараметры.СтруктураПараметровКоманды;
		
		Если РезультатЗакрытия = Неопределено Тогда 
			Возврат;
		ИначеЕсли РезультатЗакрытия.Значение = ПредопределенноеЗначение("Перечисление.ВариантыРасчетаНДС.НДСВСумме") Тогда
			СтруктураЦеныИВалюта.Вставить("ПредСуммаВключаетНДС", СтруктураЦеныИВалюта.СуммаВключаетНДС);
			СтруктураЦеныИВалюта.СуммаВключаетНДС 	= Истина;
		Иначе
			СтруктураЦеныИВалюта.Вставить("ПредСуммаВключаетНДС", СтруктураЦеныИВалюта.СуммаВключаетНДС);
			СтруктураЦеныИВалюта.СуммаВключаетНДС 	= Ложь;
		КонецЕсли;
			
	Иначе
		СтруктураЦеныИВалюта = РезультатЗакрытия;
	КонецЕсли;
	
	// Перезаполняем табличную часть если были внесены изменения в форме "Цены и Валюта".
	Если ТипЗнч(СтруктураЦеныИВалюта) = Тип("Структура") Тогда

		ВалютаДоИзменения 	 = Объект.ВалютаДокумента;
		КурсДоИзменения 	 = Объект.КурсВзаиморасчетов;
		КратностьДоИзменения = Объект.КратностьВзаиморасчетов;
		
		Объект.СуммаВключаетНДС   		= СтруктураЦеныИВалюта.СуммаВключаетНДС;
		Объект.ВалютаДокумента    		= СтруктураЦеныИВалюта.ВалютаДокумента;
		Объект.КурсВзаиморасчетов 		= СтруктураЦеныИВалюта.Курс;
		Объект.ТипЦен             		= СтруктураЦеныИВалюта.ТипЦен;
		Объект.КратностьВзаиморасчетов 	= СтруктураЦеныИВалюта.Кратность;

		Модифицированность = Истина;
		
		//Обновление на бух. корп. 3.0.38.43
		//ПересчитатьНДС = СтруктураЦеныИВалюта.СуммаВключаетНДС <> СтруктураЦеныИВалюта.ПредСуммаВключаетНДС; //Нет поля ПредСуммаВключаетНДС
		ПересчитатьНДС = Ложь; 
		//<=

		ЗаполнитьРассчитатьСуммы(
			ВалютаДоИзменения,
			КурсДоИзменения,
			КратностьДоИзменения,
			ПересчитатьНДС);

		СформироватьНадписьЦеныИВалюта(ЭтаФорма);
		
	КонецЕсли;
	 	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьРассчитатьСуммы(Знач ВалютаДоИзменения, КурсДоИзменения, КратностьДоИзменения, ПересчитатьНДС = Ложь)

	ТаблицаЦенНоменклатуры = Новый ТаблицаЗначений();

	СписокНоменклатуры	= ОбщегоНазначения.ВыгрузитьКолонку(Объект.ТоварыИУслуги, "Номенклатура", Истина);

	//Обновление на бух. корп. 3.0.38.43
	//Если ЗначениеЗаполнено(Объект.ТипЦен) Тогда
	//	ТаблицаЦенНоменклатуры = Ценообразование.ПолучитьТаблицуЦенНоменклатуры(
	//		СписокНоменклатуры,
	//		Объект.ТипЦен,
	//		Объект.Дата);
	//Иначе
	//	ТаблицаЦенНоменклатуры = Ценообразование.ПолучитьТаблицуЦенНоменклатурыДокументов(
	//		СписокНоменклатуры,
	//		Перечисления.СпособыЗаполненияЦен.ПоПродажнымЦенам,
	//		Объект.Дата);
	//КонецЕсли;
	//<=
	
	Если КурсДоИзменения <> 0 И КратностьДоИзменения <> 0 Тогда
		СтруктураКурса = Новый Структура("Курс, Кратность", КурсДоИзменения, КратностьДоИзменения);
	Иначе
		СтруктураКурса = РаботаСКурсамиВалют.ПолучитьКурсВалюты(ВалютаДоИзменения, Объект.Дата);
	КонецЕсли;

	Для Каждого Строка Из Объект.ТоварыИУслуги Цикл
		
		ЦенаВключаетНДС = НЕ Объект.СуммаВключаетНДС;

   		НайденнаяСтрока = ТаблицаЦенНоменклатуры.Найти(Строка.Номенклатура, "Номенклатура");
			
		Если НайденнаяСтрока <> Неопределено Тогда
			
			Строка.Цена = РаботаСКурсамиВалютКлиентСервер.ПересчитатьИзВалютыВВалюту(
				НайденнаяСтрока.Цена, НайденнаяСтрока.Валюта, Объект.ВалютаДокумента, НайденнаяСтрока.Курс,
				Объект.КурсВзаиморасчетов, НайденнаяСтрока.Кратность, Объект.КратностьВзаиморасчетов);
			ЦенаВключаетНДС = НайденнаяСтрока.ЦенаВключаетНДС;
			
		Иначе
			
			Строка.Цена	= РаботаСКурсамиВалютКлиентСервер.ПересчитатьИзВалютыВВалюту(
				Строка.Цена,
				ВалютаДоИзменения, Объект.ВалютаДокумента,
				СтруктураКурса.Курс, Объект.КурсВзаиморасчетов,
				СтруктураКурса.Кратность, Объект.КратностьВзаиморасчетов);
				
		КонецЕсли;

		Если ПересчитатьНДС Тогда
			Строка.Цена = УчетНДСКлиентСервер.ПересчитатьЦенуПриИзмененииФлаговНалогов(
				Строка.Цена,
				ЦенаВключаетНДС,
				Объект.СуммаВключаетНДС,
				УчетНДСВызовСервераПовтИсп.ПолучитьСтавкуНДС(Строка.СтавкаНДС));
		КонецЕсли;

		Строка.Сумма 	= Строка.Цена * ?(Строка.Количество = 0, 1, Строка.Количество);
		Строка.СуммаНДС = УчетНДСКлиентСервер.РассчитатьСуммуНДС(Строка.Сумма,
			Объект.СуммаВключаетНДС,
			УчетНДСВызовСервераПовтИсп.ПолучитьСтавкуНДС(Строка.СтавкаНДС));

		Строка.Всего = Строка.Сумма + ?(Объект.СуммаВключаетНДС, 0, Строка.СуммаНДС);

	КонецЦикла;

	ОбновитьИтоги(ЭтаФорма);

КонецПроцедуры

&НаСервере
Процедура ДатаПриИзмененииНаСервере()
	
	ДатаОбработатьИзменение();
	
	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура ДатаОбработатьИзменение()
	
	УстановитьФункциональныеОпцииФормы();
	
	Если Объект.ВалютаДокумента <> ВалютаРегламентированногоУчета Тогда
		СтруктураКурсаДокумента        = РаботаСКурсамиВалют.ПолучитьКурсВалюты(Объект.ВалютаДокумента, Объект.Дата);
		Объект.КурсВзаиморасчетов      = СтруктураКурсаДокумента.Курс;
		Объект.КратностьВзаиморасчетов = СтруктураКурсаДокумента.Кратность;
	КонецЕсли;
	
	ПрямаяЗаписьВКнигу = УпрощенныйУчетНДС ИЛИ Объект.Дата >= '20120101';
	Если ПрямаяЗаписьВКнигу Тогда 
		Объект.ПрямаяЗаписьВКнигу = Истина;
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ОрганизацияПриИзмененииНаСервере()

	ОрганизацияОбработатьИзменение();
	
	УправлениеФормой(ЭтаФорма);

КонецПроцедуры

&НаСервере
Процедура ОрганизацияОбработатьИзменение()

	УстановитьФункциональныеОпцииФормы();
	
	Объект.ПрямаяЗаписьВКнигу = УпрощенныйУчетНДС ИЛИ Объект.Дата >= '20120101';
	
	КонтрагентОбработатьИзменение();

КонецПроцедуры

&НаСервере
Процедура КонтрагентПриИзмененииНаСервере()

	КонтрагентОбработатьИзменение();
	
	УправлениеФормой(ЭтаФорма);

КонецПроцедуры

&НаСервере
Процедура КонтрагентОбработатьИзменение()

	БухгалтерскийУчетПереопределяемый.УстановитьДоговорКонтрагента(
		Объект.ДоговорКонтрагента, Объект.Контрагент, Объект.Организация,
		Неопределено);
	
	Если ЗначениеЗаполнено(Объект.ДоговорКонтрагента) Тогда
		ДоговорКонтрагентаОбработатьИзменение();
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ДоговорКонтрагентаПриИзмененииНаСервере()

	ДоговорКонтрагентаОбработатьИзменение();
	
	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура ДоговорКонтрагентаОбработатьИзменение()

	ВалютаДоИзменения 		= Объект.ВалютаДокумента;
	КурсДоИзменения   		= Объект.КурсВзаиморасчетов;
	КратностьДоИзменения   	= Объект.КратностьВзаиморасчетов;
	ТипЦенДоИзменения 		= Объект.ТипЦен;
	СуммаВключаетНДСДоИзменения = Объект.СуммаВключаетНДС;

	РеквизитыДоговора = БухгалтерскийУчетПереопределяемый.ПолучитьРеквизитыДоговораКонтрагента(Объект.ДоговорКонтрагента);

	Объект.ВалютаДокумента         = РеквизитыДоговора.ВалютаВзаиморасчетов;
	СтруктураКурсаДокумента        = РаботаСКурсамиВалют.ПолучитьКурсВалюты(Объект.ВалютаДокумента, Объект.Дата);
	Объект.КурсВзаиморасчетов      = СтруктураКурсаДокумента.Курс;
	Объект.КратностьВзаиморасчетов = СтруктураКурсаДокумента.Кратность;

	Если ЗначениеЗаполнено(РеквизитыДоговора.ТипЦен) Тогда
		 Объект.ТипЦен           = РеквизитыДоговора.ТипЦен;
		 Объект.СуммаВключаетНДС = РеквизитыДоговора.ТипЦен.ЦенаВключаетНДС;
	КонецЕсли;
	
	ПересчитатьЦены = Объект.ВалютаДокумента <> ВалютаДоИзменения
		ИЛИ Объект.КурсВзаиморасчетов <> КурсДоИзменения
		ИЛИ Объект.ТипЦен <> ТипЦенДоИзменения;
	ПересчитатьНДС = Объект.СуммаВключаетНДС <> СуммаВключаетНДСДоИзменения;
	
	Если Объект.ТоварыИУслуги.Количество() > 0 И (ПересчитатьЦены ИЛИ ПересчитатьНДС) Тогда
		ЗаполнитьРассчитатьСуммы(ВалютаДоИзменения, КурсДоИзменения, КратностьДоИзменения, ПересчитатьНДС);
	КонецЕсли;
	
	ЭтоКомиссия = БухгалтерскийУчетПереопределяемый.ЭтоВидДоговораСКомиссионером(РеквизитыДоговора.ВидДоговора);
	РасчетыВУЕ = ЗначениеЗаполнено(Объект.ДоговорКонтрагента) И РеквизитыДоговора.РасчетыВУсловныхЕдиницах;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеФормой(Форма)

	Элементы = Форма.Элементы;
	Объект   = Форма.Объект;

	//Обновление на бух. корп. 3.0.38.43
	//Элементы.ПрямаяЗаписьВКнигу.Доступность = НЕ (Форма.УпрощенныйУчетНДС ИЛИ Объект.Дата >= '20120101');
	Элементы.ПрямаяЗаписьВКнигу.Доступность = Истина;
	//<=

	Элементы.ФормироватьПроводки.Доступность                           = Объект.ПрямаяЗаписьВКнигу;
	Элементы.ЗаписьДополнительногоЛиста.Доступность                    = Объект.ПрямаяЗаписьВКнигу;
	Элементы.ФормироватьСторнирующиеЗаписиДопЛистовВручную.Доступность = Объект.ПрямаяЗаписьВКнигу;
	Элементы.КорректируемыйПериод.Доступность                          = Объект.ПрямаяЗаписьВКнигу;

	// Доступность взаимосвязанных полей
	Элементы.ПодразделениеОрганизации.Доступность = ЗначениеЗаполнено(Объект.Организация);
	Элементы.ДоговорКонтрагента.Доступность = ЗначениеЗаполнено(Объект.Организация) И ЗначениеЗаполнено(Объект.Контрагент);
	Элементы.РасчетныйДокумент.Доступность  = ЗначениеЗаполнено(Объект.ДоговорКонтрагента); 
	
	// Счет-фактура
	Если НЕ ЗначениеЗаполнено(Форма.СчетФактура) Тогда
		Элементы.ГруппаСчетФактураСтраницы.ТекущаяСтраница = Элементы.ГруппаВыписатьСчетФактуру;
	Иначе
		Элементы.ГруппаСчетФактураСтраницы.ТекущаяСтраница = Элементы.ГруппаСчетФактураСсылка;
	КонецЕсли;
	
	ОбновитьИтоги(Форма);
	СформироватьНадписьЦеныИВалюта(Форма);

КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура ОбновитьИтоги(Форма)

	Форма.ИтогиВсего = Форма.Объект.ТоварыИУслуги.Итог("Всего");

КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьНоменклатурнуюГруппуНоменклатуры(Номенклатура)
	
	ИмяРеквизитаНоменклатурнаяГруппа = БухгалтерскийУчетКлиентСерверПереопределяемый.ПолучитьИмяРеквизитаНоменклатурнаяГруппаНоменклатуры();
	Возврат ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Номенклатура, ИмяРеквизитаНоменклатурнаяГруппа);
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура СформироватьНадписьЦеныИВалюта(Форма)
	
	Объект = Форма.Объект;
	СтруктураНадписи = Новый Структура(
		"ВалютаДокумента, Курс, Кратность, СуммаВключаетНДС, ВалютаРегламентированногоУчета",
		Объект.ВалютаДокумента,
		Объект.КурсВзаиморасчетов,
		Объект.КратностьВзаиморасчетов,
		Объект.СуммаВключаетНДС,
		Форма.ВалютаРегламентированногоУчета);
		
	Если Форма.ИспользоватьТипыЦенНоменклатуры Тогда
		СтруктураНадписи.Вставить("ТипЦен", Объект.ТипЦен);
	КонецЕсли;
	
	Форма.ЦеныИВалюта = ОбщегоНазначенияБПКлиентСервер.СформироватьНадписьЦеныИВалюта(СтруктураНадписи);

КонецПроцедуры 

&НаСервере
Процедура УстановитьФункциональныеОпцииФормы()

	//Обновление на бух. корп. 3.0.38.43
	//ОбщегоНазначенияБПКлиентСервер.УстановитьПараметрыФункциональныхОпцийФормыДокумента(ЭтаФорма);
	//УпрощенныйУчетНДС	= УчетнаяПолитика.УпрощенныйУчетНДС(Объект.Организация, Объект.Дата);
	//ИспользоватьТипыЦенНоменклатуры	 = ПолучитьФункциональнуюОпцию("ИспользоватьТипыЦенНоменклатуры");
	//ЕстьВалютныйУчет 				 = БухгалтерскийУчетПереопределяемый.ИспользоватьВалютныйУчет();
	ЕстьВалютныйУчет = Истина;
	УпрощенныйУчетНДС = Ложь;
	ИспользоватьТипыЦенНоменклатуры = Ложь;
	//<=

КонецПроцедуры 

&НаКлиенте
Процедура ЗаполнитьСчетаУчетаВСтрокеТоваров(СтрокаТЧ, СчетаУчета)

	СтрокаТЧ.СчетУчета                = СчетаУчета.СчетУчета;
	СтрокаТЧ.СчетУчетаНДСПоРеализации = СчетаУчета.СчетУчетаНДСПродажи;
	СтрокаТЧ.СчетДоходов              = СчетаУчета.СчетДоходов;

КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииСчетаДохода(Элемент)

	//Обновление на бух. корп. 3.0.38.43
	//ТекущиеДанные = Элементы.ТоварыУслуги.ТекущиеДанные;
	//Если НЕ ЗначениеЗаполнено(ТекущиеДанные.СчетДоходов) Тогда
	//	ТекущиеДанные.Субконто = Неопределено;
	//	Возврат;
	//КонецЕсли;

	//СвойстваСчетаДоходов = БухгалтерскийУчетВызовСервераПовтИсп.ПолучитьСвойстваСчета(ТекущиеДанные.СчетДоходов);
	//Если СвойстваСчетаДоходов.КоличествоСубконто > 0 Тогда

	//	ТекущиеДанные.Субконто = СвойстваСчетаДоходов.ВидСубконто1ТипЗначения.ПривестиЗначение(ТекущиеДанные.Субконто);
	//	Если СвойстваСчетаДоходов.ВидСубконто1 = ПредопределенноеЗначение("ПланВидовХарактеристик.ВидыСубконтоХозрасчетные.НоменклатурныеГруппы")
	//		И ЗначениеЗаполнено(ТекущиеДанные.Номенклатура) И НЕ ЗначениеЗаполнено(ТекущиеДанные.Субконто) Тогда

	//		ТекущиеДанные.Субконто = ПолучитьНоменклатурнуюГруппуНоменклатуры(ТекущиеДанные.Номенклатура);

	//	КонецЕсли;

	//Иначе
	//	ТекущиеДанные.Субконто = Неопределено;
	//КонецЕсли;
	//<=
	
КонецПроцедуры

&НаКлиенте
Процедура ПересчитатьСуммуТовары(ТекущиеДанные)

	ОбщегоНазначенияБПКлиент.ПересчитатьСумму(ТекущиеДанные, Объект.СуммаВключаетНДС);

КонецПроцедуры

&НаСервере
Процедура ПометитьНаУдалениеСчетФактуру()

	УчетНДСПереопределяемый.ПометитьНаУдалениеСчетФактуру(СчетФактура);

КонецПроцедуры

&НаСервере
Процедура ПодготовитьФормуНаСервере()

	ТекущаяДатаДокумента			= Объект.Дата;

	ВалютаРегламентированногоУчета 	= Константы.ВалютаРегламентированногоУчета.Получить();
	
	УстановитьФункциональныеОпцииФормы();
	
	УстановитьСостояниеДокумента();
	
	ЗаполнитьРеквизитыПроСчетФактуру(ЭтаФорма);

	Если ЗначениеЗаполнено(Объект.ДоговорКонтрагента) Тогда
		РеквизитыДоговора = БухгалтерскийУчетПереопределяемый.ПолучитьРеквизитыДоговораКонтрагента(Объект.ДоговорКонтрагента);
		ЭтоКомиссия       = БухгалтерскийУчетПереопределяемый.ЭтоВидДоговораСКомиссионером(РеквизитыДоговора.ВидДоговора);
		РасчетыВУЕ        = РеквизитыДоговора.РасчетыВУсловныхЕдиницах;
	Иначе
		ЭтоКомиссия		  = Ложь;
		РасчетыВУЕ        = Ложь;
	КонецЕсли;

	ЗаполнитьДобавленныеКолонкиТаблиц();

	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры 

&НаСервере
Процедура УстановитьСостояниеДокумента()
	
	СостояниеДокумента = ОбщегоНазначенияБП.СостояниеДокумента(Объект);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьДобавленныеКолонкиТаблиц()

	ПараметрыКонтекста = Новый Структура();
	ПараметрыКонтекста.Вставить("Организация", 	Объект.Организация);
	ПараметрыКонтекста.Вставить("Дата", 		Объект.Дата);

	Для каждого СтрокаТаблицы Из Объект.ТоварыИУслуги Цикл

		СтрокаТаблицы.Всего = СтрокаТаблицы.Сумма + ?(Объект.СуммаВключаетНДС, 0, СтрокаТаблицы.СуммаНДС);

		//Обновление на бух. корп. 3.0.38.43
		//Если СтрокаТаблицы.Номенклатура = Неопределено Тогда
		//	СтрокаТаблицы.НоменклатураКод = "";
		//	СтрокаТаблицы.НоменклатураАртикул = "";
		//ИначеЕсли ТипЗнч(СтрокаТаблицы.Номенклатура) = Тип("СправочникСсылка.Номенклатура") Тогда
		//	РеквизитыНоменклатуры = БухгалтерскийУчетПереопределяемый.ПолучитьСведенияОНоменклатуре(СтрокаТаблицы.Номенклатура, ПараметрыКонтекста);
		//	СтрокаТаблицы.НоменклатураКод = РеквизитыНоменклатуры.Код;
		//	СтрокаТаблицы.НоменклатураАртикул = РеквизитыНоменклатуры.Артикул;
		//Иначе
		//	СтрокаТаблицы.НоменклатураКод = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаТаблицы.Номенклатура, "Код");
		//	СтрокаТаблицы.НоменклатураАртикул = "";
		//КонецЕсли;
		//<=
		
	КонецЦикла;

КонецПроцедуры

&НаСервере
Процедура ЗаполнитьПоРасчетномуДокументуНаСервере(РежимДобавления)

	ОбъектФормы = РеквизитФормыВЗначение("Объект");
	ОбъектФормы.ЗаполнитьПоРасчетномуДокументу(РежимДобавления);
	ЗначениеВРеквизитФормы(ОбъектФормы, "Объект");
	ЗаполнитьДобавленныеКолонкиТаблиц();
	ОбновитьИтоги(ЭтаФорма);

КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьСведенияОНоменклатуре(Знач Номенклатура, Знач СтруктураПараметров)
	
	Если Не ЗначениеЗаполнено(СтруктураПараметров.ТипЦен) Тогда
		СтруктураПараметров.Вставить("СпособЗаполненияЦены", Перечисления.СпособыЗаполненияЦен.ПоПродажнымЦенам);
	КонецЕсли;

	Возврат БухгалтерскийУчетПереопределяемый.ПолучитьСведенияОНоменклатуре(Номенклатура, СтруктураПараметров);

КонецФункции 

&НаКлиенте
Процедура ВопросЗаполнитьПоРасчетномуДокументуЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		Объект.ТоварыИУслуги.Очистить();
		ЗаполнитьПоРасчетномуДокументуНаСервере(Ложь);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВопросИспользоватьДокументРасчетовКакСФЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		ПометитьНаУдалениеСчетФактуру();
		СчетФактура = Неопределено;
	Иначе
		Объект.ИспользоватьДокументРасчетовКакСчетФактуру = Ложь;
	КонецЕсли;
	
	ЗаполнитьРеквизитыПроСчетФактуру(ЭтаФорма);
	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ БСП

// СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки

&НаСервере
Процедура ДополнительныеОтчетыИОбработкиВыполнитьНазначаемуюКомандуНаСервере(ИмяЭлемента, РезультатВыполнения)
	
	//Обновление на бух. корп. 3.0.38.43
	//ДополнительныеОтчетыИОбработки.ВыполнитьНазначаемуюКомандуНаСервере(ЭтаФорма, ИмяЭлемента, РезультатВыполнения);
	//<=
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ВыполнитьНазначаемуюКоманду(Команда)
	
	//Обновление на бух. корп. 3.0.38.43
	//Если НЕ ДополнительныеОтчетыИОбработкиКлиент.ВыполнитьНазначаемуюКомандуНаКлиенте(ЭтаФорма, Команда.Имя) Тогда
	//	РезультатВыполнения = Неопределено;
	//	ДополнительныеОтчетыИОбработкиВыполнитьНазначаемуюКомандуНаСервере(Команда.Имя, РезультатВыполнения);
	//	ДополнительныеОтчетыИОбработкиКлиент.ПоказатьРезультатВыполненияКоманды(ЭтаФорма, РезультатВыполнения);
	//КонецЕсли;
	//<=
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки

// СтандартныеПодсистемы.Печать
&НаКлиенте
Процедура Подключаемый_ВыполнитьКомандуПечати(Команда)
	
	УправлениеПечатьюКлиент.ВыполнитьПодключаемуюКомандуПечати(Команда, ЭтаФорма, Объект);
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.Печать


////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ПОЛЕЙ ФОРМЫ
//

&НаКлиенте
Процедура ДатаПриИзменении(Элемент)

	Если НачалоДня(Объект.Дата) = НачалоДня(ТекущаяДатаДокумента) Тогда
		// Изменение времени не влияет на поведение документа.
		ТекущаяДатаДокумента = Объект.Дата;
		Возврат;
	КонецЕсли;

	// Общие проверки условий по датам.
	ТребуетсяВызовСервера = ОбщегоНазначенияБПКлиент.ТребуетсяВызовСервераПриИзмененииДатыДокумента(Объект.Дата, 
		ТекущаяДатаДокумента, Объект.ВалютаДокумента, ВалютаРегламентированногоУчета);
		
	// Если определили, что изменение даты может повлиять на какие-либо параметры, 
	// то передаем обработку на сервер.
	Если ТребуетсяВызовСервера Тогда
		ДатаПриИзмененииНаСервере();
	КонецЕсли;
	
	// Запомним новую дату документа.
	ТекущаяДатаДокумента = Объект.Дата;

КонецПроцедуры

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)

	Если ЗначениеЗаполнено(Объект.Организация) Тогда
		ОрганизацияПриИзмененииНаСервере();
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)

	Если ЗначениеЗаполнено(Объект.Контрагент) Тогда
		КонтрагентПриИзмененииНаСервере();
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ДоговорКонтрагентаПриИзменении(Элемент)

	Если ЗначениеЗаполнено(Объект.ДоговорКонтрагента) Тогда
		ДоговорКонтрагентаПриИзмененииНаСервере();
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура РасчетныйДокументПриИзменении(Элемент)
	
	Если Объект.ИспользоватьДокументРасчетовКакСчетФактуру Тогда
		СчетФактура = Неопределено;
		ЗаполнитьРеквизитыПроСчетФактуру(ЭтаФорма);
	КонецЕсли;

	УправлениеФормой(ЭтаФорма);

КонецПроцедуры

&НаКлиенте
Процедура ПрямаяЗаписьВКнигуПриИзменении(Элемент)

	Если НЕ Объект.ПрямаяЗаписьВКнигу Тогда
		Объект.ФормироватьПроводки        = Ложь;
		Объект.ЗаписьДополнительногоЛиста = Ложь;
		Объект.КорректируемыйПериод       = '00010101';
		Объект.ФормироватьСторнирующиеЗаписиДопЛистовВручную = Ложь;
	КонецЕсли;

	УправлениеФормой(ЭтаФорма);

КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьДокументРасчетовКакСчетФактуруПриИзменении(Элемент)

	Если ЗначениеЗаполнено(СчетФактура) Тогда
		
		Если Объект.ИспользоватьДокументРасчетовКакСчетФактуру Тогда

			// Определим, является ли текущий счет-фактура собственным или от расчетного документ
			СобственныйСчетФактура = НайтиПодчиненныйСчетФактуруВыданныйНаРеализацию(Объект.Ссылка);

			Если СчетФактура = СобственныйСчетФактура Тогда
				ТекстВопроса = ВернутьСтр("ru = 'Требуется пометить на удаление подчиненный документ ""%1"". Продолжить?'");
				ТекстВопроса = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстВопроса, Строка(СчетФактура));
				Оповещение = Новый ОписаниеОповещения("ВопросИспользоватьДокументРасчетовКакСФЗавершение", ЭтотОбъект);
				ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет);
			Иначе
				ЗаполнитьРеквизитыПроСчетФактуру(ЭтаФорма);
				УправлениеФормой(ЭтаФорма);
			КонецЕсли;
		Иначе
			СчетФактура = Неопределено;
			ЗаполнитьРеквизитыПроСчетФактуру(ЭтаФорма);
			УправлениеФормой(ЭтаФорма);
		КонецЕсли;
	Иначе
		ЗаполнитьРеквизитыПроСчетФактуру(ЭтаФорма);
		УправлениеФормой(ЭтаФорма);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЦеныИВалютаНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ОбработатьИзмененияПоКнопкеЦеныИВалюты();

КонецПроцедуры

&НаКлиенте
Процедура ГруппаСтраницыПриСменеСтраницы(Элемент, ТекущаяСтраница)
	
	ОбновитьУсловноеОформление(ЭтотОбъект);

КонецПроцедуры

&НаКлиенте
Процедура НадписьСчетФактураНажатие(Элемент, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	//Обновление на бух. корп. 3.0.38.43
	//БухгалтерскийУчетКлиентПереопределяемый.ОткрытьСчетФактуру(ЭтаФорма, СчетФактура, "СчетФактураВыданный");
	УчетНДСКлиент.ОткрытьСчетФактуру(ЭтаФорма, СчетФактура, "СчетФактураВыданный");
	//<=                                                                           

КонецПроцедуры

&НаКлиенте
Процедура КомментарийНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ОбщегоНазначенияКлиент.ПоказатьФормуРедактированияКомментария(Элемент.ТекстРедактирования, ЭтаФорма, "Объект.Комментарий");
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьКодСправочника(Элемент)
	
	Если ЗначениеЗаполнено(Элемент) Тогда
		Возврат ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Элемент, "Код");
	Иначе
		Возврат "";
	КонецЕсли;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ДЕЙСТВИЯ КОМАНДНЫХ ПАНЕЛЕЙ ФОРМЫ
//

&НаКлиенте
Процедура ЗаполнитьПоРасчетномуДокументу(Команда)

	Если Объект.ТоварыИУслуги.Количество() > 0 Тогда
		ТекстВопроса = ВернутьСтр("ru = 'Перед заполнением табличная часть будет очищена. Продолжить?'");
		Оповещение = Новый ОписаниеОповещения("ВопросЗаполнитьПоРасчетномуДокументуЗавершение", ЭтотОбъект);
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Да);
	Иначе
		ЗаполнитьПоРасчетномуДокументуНаСервере(Ложь);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьИзРасчетногоДокумента(Команда)

	ЗаполнитьПоРасчетномуДокументуНаСервере(Истина);

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ТАБЛИЦЫ "ТОВАРЫ И УСЛУГИ"
//

&НаКлиенте
Процедура ТоварыУслугиПриИзменении(Элемент)

	ОбновитьИтоги(ЭтаФорма);

КонецПроцедуры

&НаКлиенте
Процедура ТоварыУслугиПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
	
	Если НоваяСтрока И ОтменаРедактирования Тогда
		ОбновитьИтоги(ЭтаФорма);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыУслугиПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	Если НоваяСтрока И НЕ Копирование Тогда
		Элемент.ТекущиеДанные.СтавкаНДС = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС18");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыУслугиНоменклатураПриИзменении(Элемент)

	ТекущиеДанные = Элементы.ТоварыУслуги.ТекущиеДанные;

	Если НЕ ЗначениеЗаполнено(ТекущиеДанные.Номенклатура) Тогда

		ТекущиеДанные.НоменклатураКод = "";
		ТекущиеДанные.НоменклатураАртикул = "";

	ИначеЕсли ТипЗнч(ТекущиеДанные.Номенклатура) = Тип("СправочникСсылка.Номенклатура") Тогда

		ПараметрыКонтекста = Новый Структура();
		ПараметрыКонтекста.Вставить("Дата",                    Объект.Дата);
		ПараметрыКонтекста.Вставить("Организация",             Объект.Организация);
		ПараметрыКонтекста.Вставить("ТипЦен",                  Объект.ТипЦен);
		ПараметрыКонтекста.Вставить("ВалютаДокумента",         Объект.ВалютаДокумента);
		ПараметрыКонтекста.Вставить("КурсВзаиморасчетов",      Объект.КурсВзаиморасчетов);
		ПараметрыКонтекста.Вставить("КратностьВзаиморасчетов", Объект.КратностьВзаиморасчетов);
		ПараметрыКонтекста.Вставить("СуммаВключаетНДС",        Объект.СуммаВключаетНДС);
		ПараметрыКонтекста.Вставить("СтавкаНДС",               ТекущиеДанные.СтавкаНДС);

		//Обновление на бух. корп. 3.0.38.43
		//ПараметрыНоменклатуры = ПолучитьСведенияОНоменклатуре(ТекущиеДанные.Номенклатура, ПараметрыКонтекста);

		//Если ЗначениеЗаполнено(ПараметрыНоменклатуры.Цена) Тогда
		//	ТекущиеДанные.Цена  = ПараметрыНоменклатуры.Цена;
		//	ТекущиеДанные.Сумма = ТекущиеДанные.Цена * ТекущиеДанные.Количество;
		//КонецЕсли;

		//ТекущиеДанные.Субконто  = ПараметрыНоменклатуры.НоменклатурнаяГруппа;

		//ТекущиеДанные.СтавкаНДС = ПараметрыНоменклатуры.СтавкаНДС;
		//ОбщегоНазначенияБПКлиент.ПересчитатьСуммуНДС(ТекущиеДанные, Объект.СуммаВключаетНДС);

		//ЗаполнитьСчетаУчетаВСтрокеТоваров(ТекущиеДанные, ПараметрыНоменклатуры.СчетаУчета);

		//ТекущиеДанные.НоменклатураКод = ПараметрыНоменклатуры.Код;
		//ТекущиеДанные.НоменклатураАртикул = ПараметрыНоменклатуры.Артикул;
		//<=
		
	Иначе

		ТекущиеДанные.НоменклатураКод = ПолучитьКодСправочника(ТекущиеДанные.Номенклатура);
		ТекущиеДанные.НоменклатураАртикул = "";

	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ТоварыУслугиСчетДоходовПриИзменении(Элемент)

	ПриИзмененииСчетаДохода(Элемент);

КонецПроцедуры

&НаКлиенте
Процедура ТоварыУслугиСуммаНДСПриИзменении(Элемент)

	ТекущиеДанные = Элементы.ТоварыУслуги.ТекущиеДанные;
	ТекущиеДанные.Всего = ТекущиеДанные.Сумма + ?(Объект.СуммаВключаетНДС, 0, ТекущиеДанные.СуммаНДС);

КонецПроцедуры

&НаКлиенте
Процедура ТоварыУслугиСуммаПриИзменении(Элемент)

	ТекущиеДанные = Элементы.ТоварыУслуги.ТекущиеДанные;
	ТекущиеДанные.Цена = ТекущиеДанные.Сумма / ?(ТекущиеДанные.Количество = 0, 1, ТекущиеДанные.Количество);
	ОбщегоНазначенияБПКлиент.ПересчитатьСуммуНДС(ТекущиеДанные, Объект.СуммаВключаетНДС);

КонецПроцедуры

&НаКлиенте
Процедура ТоварыУслугиКоличествоПриИзменении(Элемент)

	ТекущиеДанные = Элементы.ТоварыУслуги.ТекущиеДанные;
	ПересчитатьСуммуТовары(ТекущиеДанные);

КонецПроцедуры

&НаКлиенте
Процедура ТоварыУслугиЦенаПриИзменении(Элемент)

	ТекущиеДанные = Элементы.ТоварыУслуги.ТекущиеДанные;
	ПересчитатьСуммуТовары(ТекущиеДанные);

КонецПроцедуры

&НаКлиенте
Процедура ТоварыУслугиСтавкаНДСПриИзменении(Элемент)

	ТекущиеДанные = Элементы.ТоварыУслуги.ТекущиеДанные;
	ОбщегоНазначенияБПКлиент.ПересчитатьСуммуНДС(ТекущиеДанные, Объект.СуммаВключаетНДС);

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ
//

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	//Обновление на бух. корп. 3.0.38.43
	//// СтандартныеПодсистемы.Печать
	//УправлениеПечатью.ПриСозданииНаСервере(ЭтаФорма, Элементы.ГруппаПечать);
	//// Конец СтандартныеПодсистемы.Печать
	//
	//// ДополнительныеОтчетыИОбработки
	//ДополнительныеОтчетыИОбработки.ПриСозданииНаСервере(ЭтаФорма);
	//// Конец ДополнительныеОтчетыИОбработки
	//
	//// СтандартныеПодсистемы.ВерсионированиеОбъектов
	//ВерсионированиеОбъектов.ПриСозданииНаСервере(ЭтотОбъект);
	//// Конец СтандартныеПодсистемы.ВерсионированиеОбъектов
	//
	//Если Параметры.Ключ.Пустая() Тогда
	//	ПодготовитьФормуНаСервере();
	//	Объект.ПрямаяЗаписьВКнигу = УпрощенныйУчетНДС ИЛИ Объект.Дата >= '20120101';
	//КонецЕсли;
	//<=
	
	УправлениеФормой(ЭтаФорма);
	
	УстановитьУсловноеОформление();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)

	Если ИмяСобытия = "Запись_СчетФактураВыданный"
		И Параметр.ДокументыОснования.Найти(Объект.Ссылка) <> Неопределено Тогда
		ЗаполнитьРеквизитыПроСчетФактуру(ЭтаФорма, Параметр.РеквизитыСФ);
		УправлениеФормой(ЭтаФорма);
	Иначе
		ОбщегоНазначенияБПКлиент.ОбработкаОповещенияФормыДокумента(ЭтаФорма, Объект.Ссылка, ИмяСобытия, Параметр, Источник);
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	//Обновление на бух. корп. 3.0.38.43
	//// СтандартныеПодсистемы.ДатыЗапретаИзменения
	//ДатыЗапретаИзменения.ОбъектПриЧтенииНаСервере(ЭтаФорма, ТекущийОбъект);
	//// Конец СтандартныеПодсистемы.ДатыЗапретаИзменения
	//<=
	
	ПодготовитьФормуНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	Если ПараметрыЗаписи.РежимЗаписи = ПредопределенноеЗначение("РежимЗаписиДокумента.Проведение") Тогда
		//Обновление на бух. корп. 3.0.38.43
		//КлючеваяОперация = "ПроведениеОтражениеНачисленияНДС";
		//ОценкаПроизводительностиКлиентСервер.НачатьЗамерВремени(КлючеваяОперация);
		//<=
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)

	ЗаполнитьДобавленныеКолонкиТаблиц();
	
	Если ПараметрыЗаписи.Свойство("ВыписатьСчетФактуру") 
		И ПараметрыЗаписи.ВыписатьСчетФактуру Тогда 
		
		Если ТекущийОбъект.ИспользоватьДокументРасчетовКакСчетФактуру Тогда
			Основание = ТекущийОбъект.РасчетныйДокумент;
		Иначе
			Основание = ТекущийОбъект.Ссылка;
		КонецЕсли;
			
		РеквизитыСФ = УчетНДСВызовСервера.СоздатьСчетФактуруВыданныйНаОсновании(Основание);
		
		ЗаполнитьРеквизитыПроСчетФактуру(ЭтаФорма, РеквизитыСФ);
		
		УправлениеФормой(ЭтаФорма);
		
	КонецЕсли;
	
	//Обновление на бух. корп. 3.0.38.43
	//Если Не ЗначениеЗаполнено(Объект.ТипЦен) Тогда
	//	Ценообразование.ОбновитьЦеныНоменклатуры(Объект.Ссылка, 
	//		Перечисления.СпособыЗаполненияЦен.ПоПродажнымЦенам,
	//		Объект.ВалютаДокумента,
	//		Объект.СуммаВключаетНДС);
	//КонецЕсли;
	//<=
	
	УстановитьСостояниеДокумента();

КонецПроцедуры

&НаКлиенте
Процедура ВыписатьСчетФактуру(Команда)
	
	РеквизитыСФ = УчетНДСКлиент.СоздатьСчетФактуруВыданный(ЭтаФорма);
	
	Если РеквизитыСФ <> Неопределено Тогда 
		ЗаполнитьРеквизитыПроСчетФактуру(ЭтаФорма, РеквизитыСФ);
		УправлениеФормой(ЭтаФорма);
	КонецЕсли;
		
КонецПроцедуры
