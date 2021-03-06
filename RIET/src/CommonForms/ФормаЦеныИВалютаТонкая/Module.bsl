////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ
//

&НаСервере
// Процедура заполняет параметры формы.
//
Процедура ПолучитьЗначенияПараметровФормы()

	// Тип цен.
	Если Параметры.Свойство("ТипЦен") Тогда
		// Вид цены.
		ТипЦен = Параметры.ТипЦен;
		ТипЦенПриОткрытии = Параметры.ТипЦен;
		ТипЦенЕстьРеквизит = Истина;
	Иначе
		// Доступность вида цены, флаг - перезаполнить цены.
		Элементы.ТипЦен.Видимость = Ложь;
		Элементы.ПерезаполнитьЦены.Видимость = Ложь;
		ТипЦенЕстьРеквизит = Ложь;
	КонецЕсли;

	Если Параметры.Свойство("ПерезаполнитьЦены") Тогда
		ПерезаполнитьЦены = Параметры.ПерезаполнитьЦены;
	Иначе
		ПерезаполнитьЦены = Ложь;
		Элементы.ПерезаполнитьЦены.Видимость = Ложь;
	КонецЕсли;
	
	// Валюта документа.
	Если Параметры.Свойство("ВалютаДокумента") Тогда
		ВалютаДокумента = Параметры.ВалютаДокумента;
		ВалютаДокументаПриОткрытии = Параметры.ВалютаДокумента;
		ВалютаДокументаЕстьРеквизит = Истина;
	Иначе
		Элементы.ВалютаДокумента.Видимость = Ложь;
		Элементы.Курс.Видимость = Ложь;
		Элементы.Кратность.Видимость = Ложь;
		Элементы.ПересчитатьЦены.Видимость = Ложь;
		ВалютаДокументаЕстьРеквизит = Ложь;
	КонецЕсли;

	// Сумма включает НДС.
	Если Параметры.Свойство("СуммаВключаетНДС") Тогда
		СуммаВключаетНДС = Параметры.СуммаВключаетНДС;
		СуммаВключаетНДСПриОткрытии = Параметры.СуммаВключаетНДС;
		СуммаВключаетНДСЕстьРеквизит = Истина;
	Иначе
		Элементы.СуммаВключаетНДС.Видимость = Ложь;
		СуммаВключаетНДСЕстьРеквизит = Ложь;
	КонецЕсли;

	// НДС включать в стоимость.
	Если Параметры.Свойство("НДСВключенВСтоимость") Тогда
		НДСВключенВСтоимость = Параметры.НДСВключенВСтоимость;
		НДСВключенВСтоимостьПриОткрытии = Параметры.НДСВключенВСтоимость;
		НДСВключенВСтоимостьЕстьРеквизит = Истина;
	Иначе
		Элементы.НДСВключенВСтоимость.Видимость = Ложь;
		НДСВключенВСтоимостьЕстьРеквизит = Ложь;
	КонецЕсли;

	КурсДокументаЕстьРеквизит = Параметры.Свойство("КурсДокумента");
	КратностьДокументаЕстьРеквизит = Параметры.Свойство("КратностьДокумента");
	КурсЕстьРеквизит = Параметры.Свойство("Курс");
	КратностьЕстьРеквизит = Параметры.Свойство("Кратность");

	// Валюта расчетов.
	Если Параметры.Свойство("Договор") Тогда

		РеквизитыДоговор = SalesBookСервер.ПолучитьРеквизитыДоговораКонтрагента(Параметры.Договор);
		ВалютаРасчетов = РеквизитыДоговор.ВалютаВзаиморасчетов;
		РасчетыВУЕ     = РеквизитыДоговор.РасчетыВУсловныхЕдиницах;
		//Добавила Федотова Л., РГ-Софт, 19.01.15, вопрос SLI-0005089
		ФиксированныйКурс = РеквизитыДоговор.Курс;
		//
		// Если есть параметр "валюта документа" и он равен валюте из договора
		МассивКурсКратность = КурсыВалют.НайтиСтроки(Новый Структура("Валюта", ВалютаРасчетов));

		Если (ВалютаРасчетов <> ВалютаУчета) Тогда // Не рубли
			// Если валюту передали не рубли, а курс всё равно = 1, то подставить из таблицы
			Если КурсЕстьРеквизит Тогда
				//Изменила Федотова Л., РГ-Софт, 19.01.15, вопрос SLI-0005089
				КурсРасчетов = ?(ФиксированныйКурс <> 0,ФиксированныйКурс,Параметры.Курс);
				//КурсРасчетов = Параметры.Курс;
				Если КурсРасчетов = 1 Тогда
					Если НЕ Параметры.Курс = 1 Тогда
						КурсРасчетов = Параметры.Курс;
					ИначеЕсли ЗначениеЗаполнено(МассивКурсКратность) Тогда
						КурсРасчетов = МассивКурсКратность[0].Курс;
					КонецЕсли;
				КонецЕсли;
			Иначе
				Если ЗначениеЗаполнено(МассивКурсКратность) Тогда
					КурсРасчетов = МассивКурсКратность[0].Курс;
				Иначе
					КурсРасчетов = 1;
				КонецЕсли;
			КонецЕсли;
			Если КратностьЕстьРеквизит Тогда
				КратностьРасчетов = Параметры.Кратность;
			Иначе
				Если ЗначениеЗаполнено(МассивКурсКратность) Тогда
					КратностьРасчетов = МассивКурсКратность[0].Кратность;
				Иначе
					КратностьРасчетов = 1;
				КонецЕсли;
			КонецЕсли;
		Иначе
			Если НЕ Параметры.Курс = 1 Тогда
				КурсРасчетов = Параметры.Курс;
				КратностьРасчетов = Параметры.Кратность;
			ИначеЕсли ЗначениеЗаполнено(МассивКурсКратность) Тогда
				КурсРасчетов = МассивКурсКратность[0].Курс;
				КратностьРасчетов = МассивКурсКратность[0].Кратность;
			Иначе
				КурсРасчетов = 1;
				КратностьРасчетов = 1;
			КонецЕсли;
		КонецЕсли;

		КурсРасчетовПриОткрытии      = КурсРасчетов;
		КратностьРасчетовПриОткрытии = КратностьРасчетов;

		ДоговорЕстьРеквизит = Истина;

	Иначе

		Элементы.ВалютаРасчетов.Видимость = Ложь;
		Элементы.КурсРасчетов.Видимость = Ложь;
		Элементы.КратностьРасчетов.Видимость = Ложь;

		ДоговорЕстьРеквизит = Ложь;

	КонецЕсли;

	ПересчитатьЦены = Параметры.ПересчитатьЦены;

	Если ЗначениеЗаполнено(ВалютаДокумента) Тогда
		Курс = Параметры.Курс;
		Кратность = Параметры.Кратность;
		МассивКурсКратность = КурсыВалют.НайтиСтроки(Новый Структура("Валюта", ВалютаДокумента));
		//Если ВалютаДокумента = ВалютаРасчетов
		//		И КурсРасчетов <> 0
		//		И КратностьРасчетов <> 0 Тогда
		//	//Курс = КурсРасчетов;
		//	//Кратность = КратностьРасчетов;
		//Иначе
		//	Если ЗначениеЗаполнено(МассивКурсКратность) Тогда
		//		//Курс = МассивКурсКратность[0].Курс;
		//		//Кратность = МассивКурсКратность[0].Кратность;
		//	Иначе
		//		//Курс = 0;
		//		//Кратность = 0;
		//	КонецЕсли;
		//КонецЕсли;
		Если ВалютаДокумента = Константы.ВалютаРегламентированногоУчета.Получить() Тогда
			Курс = 1;
			Кратность = 1;
		КонецЕсли; 
		КурсРасчетов = ?(Параметры.Договор.Курс > 0, Параметры.Договор.Курс,КурсРасчетов);
	КонецЕсли;

КонецПроцедуры

&НаСервере
// Процедура заполняет таблицу курсов валют
//
Процедура ЗаполнитьТаблицуКурсовВалют()

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ДатаДокумента", Параметры.ДатаДокумента);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	КурсыВалютСрезПоследних.Валюта,
	|	КурсыВалютСрезПоследних.Курс,
	|	КурсыВалютСрезПоследних.Кратность
	|ИЗ
	|	РегистрСведений.КурсыВалют.СрезПоследних(&ДатаДокумента, ) КАК КурсыВалютСрезПоследних";

	ТаблицаРезультатаЗапроса = Запрос.Выполнить().Выгрузить();
	КурсыВалют.Загрузить(ТаблицаРезультатаЗапроса);

КонецПроцедуры

&НаКлиенте
// Процедура проверяет правильность заполнения реквизитов формы.
//
Процедура ПроверитьЗаполнениеРеквизитовФормы(Отказ)

	// Проверка заполненности реквизитов.

	// Вид цен.
	Если ПерезаполнитьЦены Тогда
		Если НЕ ЗначениеЗаполнено(ТипЦен) Тогда
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = ВернутьСтр("ru = 'Не выбран вид цены для заполнения!'");
			Сообщение.Поле = "ТипЦен";
			Сообщение.Сообщить();
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли;

	// Валюта документа.
	Если ВалютаДокументаЕстьРеквизит Тогда
		Если НЕ ЗначениеЗаполнено(ВалютаДокумента) Тогда
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = ВернутьСтр("ru = 'Не заполнена валюта документа!'");
			Сообщение.Поле = "ВалютаДокумента";
			Сообщение.Сообщить();
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли;

	// Расчеты.
	Если ДоговорЕстьРеквизит Тогда
		Если НЕ ЗначениеЗаполнено(КурсРасчетов) Тогда
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = ВернутьСтр("ru = 'Обнаружен нулевой курс валюты расчетов!'");
			Сообщение.Поле = "КурсРасчетов";
			Сообщение.Сообщить();
			Отказ = Истина;
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(КратностьРасчетов) Тогда
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = ВернутьСтр("ru = 'Обнаружена нулевая кратность курса валюты расчетов!'");
			Сообщение.Поле = "КратностьРасчетов";
			Сообщение.Сообщить();
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
// Процедура проверяет модифицированность формы.
//
Процедура ПроверитьМодифицированностьФормы()

	БылиВнесеныИзменения = Ложь;

	ИзмененияТипЦен               = ?(ТипЦенЕстьРеквизит, ТипЦенПриОткрытии <> ТипЦен, Ложь);
	ИзмененияВалютаДокумента      = ?(ВалютаДокументаЕстьРеквизит, ВалютаДокументаПриОткрытии <> ВалютаДокумента, Ложь);
	ИзмененияСуммаВключаетНДС     = ?(СуммаВключаетНДСЕстьРеквизит, СуммаВключаетНДСПриОткрытии <> СуммаВключаетНДС, Ложь);
	ИзмененияНДСВключенВСтоимость = ?(НДСВключенВСтоимостьЕстьРеквизит, НДСВключенВСтоимостьПриОткрытии <> НДСВключенВСтоимость, Ложь);
	ИзмененияКурсРасчетов         = ?(ДоговорЕстьРеквизит, КурсРасчетовПриОткрытии <> КурсРасчетов, Ложь);
	ИзмененияКратностьРасчетов    = ?(ДоговорЕстьРеквизит, КратностьРасчетовПриОткрытии <> КратностьРасчетов, Ложь);

	Если ПерезаполнитьЦены
			ИЛИ ПересчитатьЦены
			ИЛИ ИзмененияВалютаДокумента
			ИЛИ ИзмененияСуммаВключаетНДС
			ИЛИ ИзмененияНДСВключенВСтоимость
			ИЛИ ИзмененияКурсРасчетов
			ИЛИ ИзмененияКратностьРасчетов
			ИЛИ ИзмененияТипЦен Тогда
		БылиВнесеныИзменения = Истина;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
// Процедура заполнения курса и кратности валюты документа.
//
Процедура ЗаполнитьКурсКратностьВалютыДокумента()

	Если ЗначениеЗаполнено(ВалютаДокумента) Тогда
		МассивКурсКратность = КурсыВалют.НайтиСтроки(Новый Структура("Валюта", ВалютаДокумента));
		Если ВалютаДокумента = ВалютаРасчетов
				И КурсРасчетов <> 0
				И КратностьРасчетов <> 0 Тогда
			Курс = КурсРасчетов;
			Кратность = КратностьРасчетов;
		Иначе
			Если ЗначениеЗаполнено(МассивКурсКратность) Тогда // Если есть хотя бы 1 элемент
				//изменила Федотова Л., РГ-Софт, 14.05.15, вопрос SLI-0005415
				//Курс = МассивКурсКратность[0].Курс;
				//Кратность = МассивКурсКратность[0].Кратность;
				Курс = КурсРасчетов;
				Кратность = КратностьРасчетов;
			Иначе
				Курс = 0;
				Кратность = 0;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ
//

&НаСервере
// Процедура - обработчик события ПриСозданииНаСервере формы.
// В процедуре осуществляется
// - инициализация параметров формы.
//
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	ВалютаУчета = Константы.ВалютаРегламентированногоУчета.Получить();
	ЗаполнитьТаблицуКурсовВалют();
	ПолучитьЗначенияПараметровФормы();

	Если ДоговорЕстьРеквизит И НЕ КурсДокументаЕстьРеквизит Тогда	
		НовыйМассив = Новый Массив();
		Если РасчетыВУЕ И ВалютаУчета <> ВалютаРасчетов Тогда
			НовыйМассив.Добавить(ВалютаУчета);
		КонецЕсли;
		НовыйМассив.Добавить(ВалютаРасчетов);
		НовыйПараметр = Новый ПараметрВыбора("Отбор.Ссылка", Новый ФиксированныйМассив(НовыйМассив));
		НовыйМассив2  = Новый Массив();
		НовыйМассив2.Добавить(НовыйПараметр);
		НовыеПараметры = Новый ФиксированныйМассив(НовыйМассив2);
		Элементы.Валюта.ПараметрыВыбора = НовыеПараметры;
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ДЕЙСТВИЯ КОМАНДНЫХ ПАНЕЛЕЙ ФОРМЫ

&НаКлиенте
// Процедура - обработчик события нажатия кнопки ОК.
//
Процедура КомандаОК(Команда)

	Отказ = Ложь;

	ПроверитьЗаполнениеРеквизитовФормы(Отказ);
	ПроверитьМодифицированностьФормы();

	Если НЕ Отказ Тогда

		СтруктураРеквизитовФормы = Новый Структура;

		СтруктураРеквизитовФормы.Вставить("БылиВнесеныИзменения", БылиВнесеныИзменения);
		СтруктураРеквизитовФормы.Вставить("ТипЦен",               ТипЦен);
		СтруктураРеквизитовФормы.Вставить("ВалютаДокумента",      ВалютаДокумента);
		СтруктураРеквизитовФормы.Вставить("СуммаВключаетНДС",     СуммаВключаетНДС);
		СтруктураРеквизитовФормы.Вставить("НДСВключенВСтоимость", НДСВключенВСтоимость);
		СтруктураРеквизитовФормы.Вставить("ВалютаРасчетов",       ВалютаРасчетов);
		СтруктураРеквизитовФормы.Вставить("Курс",                 Курс);
		//СтруктураРеквизитовФормы.Вставить("Курс",                 КурсРасчетов);
		СтруктураРеквизитовФормы.Вставить("КурсРасчетов",         КурсРасчетов);
		СтруктураРеквизитовФормы.Вставить("Кратность",            Кратность);
		СтруктураРеквизитовФормы.Вставить("КратностьРасчетов",    Кратность);
		СтруктураРеквизитовФормы.Вставить("ПредВалютаДокумента",  ВалютаДокументаПриОткрытии);
		СтруктураРеквизитовФормы.Вставить("ПредСуммаВключаетНДС", СуммаВключаетНДСПриОткрытии);
		СтруктураРеквизитовФормы.Вставить("ПерезаполнитьЦены",    ПерезаполнитьЦены);
		СтруктураРеквизитовФормы.Вставить("ПересчитатьЦены",      ПересчитатьЦены);
		СтруктураРеквизитовФормы.Вставить("ИмяФормы",             "ОбщаяФорма.ФормаВалюта");

		Закрыть(СтруктураРеквизитовФормы);

	КонецЕсли;

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ РЕКВИЗИТОВ ФОРМЫ
//

&НаКлиенте
// Процедура - обработчик события ПриИзменении поля ввода ТипЦен.
//
Процедура ТипЦеныПриИзменении(Элемент)

	Если ЗначениеЗаполнено(ТипЦен) Тогда
		Если ТипЦенПриОткрытии <> ТипЦен Тогда
			ПерезаполнитьЦены = Истина;
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
// Процедура - обработчик события ПриИзменении поля ввода Валюта.
//
Процедура ВалютаПриИзменении(Элемент)

	ЗаполнитьКурсКратностьВалютыДокумента();

	Если ЗначениеЗаполнено(ВалютаДокумента)
			И ВалютаДокументаПриОткрытии <> ВалютаДокумента Тогда
		ПересчитатьЦены = Истина;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
// Процедура - обработчик события ПриИзменении поля ввода ВалютаРасчетов.
//
Процедура ВалютаРасчетовПриИзменении(Элемент)

	ЗаполнитьКурсКратностьВалютыДокумента();

КонецПроцедуры

&НаКлиенте
// Процедура - обработчик события ПриИзменении поля ввода КурсРасчетов.
//
Процедура КурсРасчетовПриИзменении(Элемент)

	ЗаполнитьКурсКратностьВалютыДокумента();

КонецПроцедуры

&НаКлиенте
// Процедура - обработчик события ПриИзменении поля ввода КратностьРасчетов.
//
Процедура КратностьРасчетовПриИзменении(Элемент)

	ЗаполнитьКурсКратностьВалютыДокумента();

КонецПроцедуры
