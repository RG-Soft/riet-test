Перем мВалютаРегламентированногоУчета Экспорт;

Перем мЗаконодательство2006 Экспорт;

Перем ВидыСубконтоСчетов;
Перем ПоддержкаПБУ18;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

#Если Клиент Тогда

// Функция формирует табличный документ с печатной формой накладной,
// разработанной методистами
//
// Возвращаемое значение:
//  Табличный документ - печатная форма накладной
//
Функция ПечатьОтчетаКомитенту()
	
	//ДопКолонка = Константы.ДополнительнаяКолонкаПечатныхФормДокументов.Получить();
	//Если ДопКолонка = Перечисления.ДополнительнаяКолонкаПечатныхФормДокументов.Артикул Тогда
	//	ВыводитьКоды    = Истина;
	//	Колонка         = "Артикул";
	//	ТекстКодАртикул = "Артикул";
	//ИначеЕсли ДопКолонка = Перечисления.ДополнительнаяКолонкаПечатныхФормДокументов.Код Тогда
	//	ВыводитьКоды    = Истина;
	//	Колонка         = "Код";
	//	ТекстКодАртикул = "Код";
	//Иначе
	//	ВыводитьКоды    = Ложь;
	//	Колонка         = "";
	//	ТекстКодАртикул = "Код";
	//КонецЕсли;

	//Если ВыводитьКоды Тогда
	//	ОбластьШапки  = "ШапкаСКодом";
	//	ОбластьСтроки = "СтрокаСКодом";
	//Иначе
		ОбластьШапки  = "ШапкаТаблицы";
		ОбластьСтроки = "Строка";
	//КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", ЭтотОбъект.Ссылка);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ОтчетКомитентуОПродажах.Номер,
	|	ОтчетКомитентуОПродажах.Дата,
	|	ОтчетКомитентуОПродажах.ДоговорКонтрагента,
	|	ОтчетКомитентуОПродажах.Контрагент,
	|	ОтчетКомитентуОПродажах.Организация,
	|	ОтчетКомитентуОПродажах.СуммаДокумента,
	|	ОтчетКомитентуОПродажах.ВалютаДокумента,
	|	ОтчетКомитентуОПродажах.СтавкаНДСВознаграждения,
	|	ОтчетКомитентуОПродажах.СуммаВознаграждения
	|ИЗ
	|	Документ.ОтчетПринципалуОПродажах КАК ОтчетКомитентуОПродажах
	|ГДЕ
	|	ОтчетКомитентуОПродажах.Ссылка = &ТекущийДокумент";
	
	Шапка = Запрос.Выполнить().Выбрать();
    Шапка.Следующий();
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", ЭтотОбъект.Ссылка);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ОтчетКомитентуОПродажахТовары.Номенклатура КАК Товар,
	|	ОтчетКомитентуОПродажахТовары.КоличествоМест КАК КоличествоМест,
	|	ОтчетКомитентуОПродажахТовары.ЕдиницаИзмерения,
	|	ОтчетКомитентуОПродажахТовары.Номенклатура.БазоваяЕдиницаИзмерения КАК ЕдиницаХранения,
	|	ОтчетКомитентуОПродажахТовары.Количество КАК Количество,
	|	ОтчетКомитентуОПродажахТовары.Цена,
	|	ОтчетКомитентуОПродажахТовары.Сумма КАК Сумма,
	|	ОтчетКомитентуОПродажахТовары.СуммаНДС КАК СуммаНДС,
	|	ОтчетКомитентуОПродажахТовары.Покупатель КАК Покупатель,
	|	ОтчетКомитентуОПродажахТовары.ДатаРеализации КАК ДатаПродажи,
	|	ОтчетКомитентуОПродажахТовары.СуммаВознаграждения КАК СуммаВознаграждения,
	|	ОтчетКомитентуОПродажахТовары.СуммаНДСВознаграждения КАК СуммаНДСВознаграждения
	|ИЗ
	|	Документ.ОтчетПринципалуОПродажах.Товары КАК ОтчетКомитентуОПродажахТовары
	|ГДЕ
	|	ОтчетКомитентуОПродажахТовары.Ссылка = &ТекущийДокумент
	|
	|УПОРЯДОЧИТЬ ПО
	|	Покупатель,
	|	ОтчетКомитентуОПродажахТовары.НомерСтроки
	|ИТОГИ
	|	СУММА(КоличествоМест),
	|	СУММА(Количество),
	|	СУММА(Сумма),
	|	СУММА(СуммаНДС),
	|	СУММА(СуммаВознаграждения),
	|	СУММА(СуммаНДСВознаграждения)
	|ПО
	|	Покупатель";
	
	ВыборкаПокупателей = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Покупатель");
	
	Итого = 0;
	ИтогоСуммаВознаграждения = 0;
	ИтогоСуммаНДСВознаграждения = 0;
	НомерПП = 1;
	
	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ОтчетКомитентуОПродажах_ОтчетКомитентуОПродажах";
	Макет       = ПолучитьМакет("ОтчетКомитентуОПродажах");

	// Выводим шапку накладной

	ОбластьМакета = Макет.ПолучитьОбласть("Заголовок");
	ОбластьМакета.Параметры.ТекстЗаголовка = РаботаСДиалогами.СформироватьЗаголовокДокумента(Шапка, "Отчет принципалу");
	ТабДокумент.Вывести(ОбластьМакета);
	
	//СведенияОбОрганизации    = КонтактнаяИнформация.СведенияОЮрФизЛице(Шапка.Организация, Шапка.Дата);
	//ПредставлениеОрганизации = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбОрганизации, "ПолноеНаименование,");
	//
	//СведенияОКонтрагенте     = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Контрагент, Шапка.Дата);
	//ПредставлениеКонтрагента = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОКонтрагенте, "ПолноеНаименование,");
	//
	ОбластьМакета = Макет.ПолучитьОбласть("Поставщик");
	ОбластьМакета.Параметры.ПредставлениеПоставщика = ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(Контрагент, Дата), "ПолноеНаименование,ЮридическийАдрес,ИНН,КПП")+ Символы.ПС + Символы.ПС;
	
	//ОбластьМакета.Параметры.Заполнить(Шапка);
	//ОбластьМакета.Параметры.ПредставлениеПоставщика = ПредставлениеКонтрагента;
	//ОбластьМакета.Параметры.Поставщик               = Шапка.Контрагент;
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Покупатель");
	ОписаниеОрг = ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(ПодразделениеОрганизации, Дата), "НаименованиеЗаказчика,");
	ОписаниеОрг = ОписаниеОрг + ", " + ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(Организация, Дата), "ЮридическийАдрес,ИНН,");
	ОписаниеКПП= ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(ПодразделениеОрганизации, Дата), "КПП,");
	ОписаниеОргФил= ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(ПодразделениеОрганизации, Дата), "ЮридическийАдрес,");
	
	ОбластьМакета.Параметры.ПредставлениеПолучателя = ОписаниеОрг+","+ОписаниеКПП+ Символы.ПС +"Адрес филиала: "+ОписаниеОргФил
	+ Символы.ПС + Символы.ПС;
	//ОбластьМакета.Параметры.Заполнить(Шапка);
	//ОбластьМакета.Параметры.ПредставлениеПолучателя = ПредставлениеОрганизации;
	ОбластьМакета.Параметры.Получатель              = Шапка.Организация;
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть(ОбластьШапки);
	//Если ВыводитьКоды Тогда
	//	ОбластьМакета.Параметры.ИмяКодАртикул = ТекстКодАртикул;
	//КонецЕсли;
	ТабДокумент.Вывести(ОбластьМакета);

	Пока ВыборкаПокупателей.Следующий() Цикл
		
		СведенияОбПокупателе = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(ВыборкаПокупателей.Покупатель, Дата);
		//ТекстПокупатель = "Покупатель: " + ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбПокупателе, "НаименованиеДляПечатныхФорм,");
		ТекстПокупатель = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбПокупателе, "НаименованиеДляПечатныхФорм,");
		//ТекстПокупатель = ТекстПокупатель + " Адрес: " + ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбПокупателе, "ЮридическийАдрес,");
		КПП = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбПокупателе, "КПП,", Ложь);
		Если ЗначениеЗаполнено(КПП) Тогда
			КПП = "/ " + КПП;
		КонецЕсли;
		//ТекстПокупатель = ТекстПокупатель + " ИНН/КПП покупателя: " + ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбПокупателе, "ИНН,", Ложь) + КПП;
		ТекстИНН_КПП = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбПокупателе, "ИНН,", Ложь) + КПП;
		
		//ОбластьМакета = Макет.ПолучитьОбласть("СтрокаПокупатель");
		//ОбластьМакета.Параметры.ПредставлениеПокупателя = ТекстПокупатель;
		//ТабДокумент.Вывести(ОбластьМакета);
		
		ОбластьМакета = Макет.ПолучитьОбласть(ОбластьСтроки);
		//ВыборкаСтрокТовары = ВыборкаПокупателей.Выбрать();
		ВыборкаСтрокТовары = ВыборкаПокупателей.Выбрать();
		
		Пока ВыборкаСтрокТовары.Следующий() Цикл
			
			ОбластьМакета.Параметры.Заполнить(ВыборкаСтрокТовары);
			ОбластьМакета.Параметры.НомерСтроки = НомерПП;
			ОбластьМакета.Параметры.Покупатель = ТекстПокупатель;
			ОбластьМакета.Параметры.ИНН_КПП = ТекстИНН_КПП;

			Если Не СуммаВключаетНДС Тогда
				СуммаПоСтроке = ВыборкаСтрокТовары.Сумма + ВыборкаСтрокТовары.СуммаНДС;
				ОбластьМакета.Параметры.Цена = ?(ВыборкаСтрокТовары.Количество <> 0, СуммаПоСтроке/ВыборкаСтрокТовары.Количество, 0);
				ОбластьМакета.Параметры.Сумма = СуммаПоСтроке;
			Иначе
				СуммаПоСтроке = ВыборкаСтрокТовары.Сумма;
			КонецЕсли;			
			ТабДокумент.Вывести(ОбластьМакета);
			
			Итого = Итого + СуммаПоСтроке;
			ИтогоСуммаВознаграждения = ИтогоСуммаВознаграждения + ВыборкаСтрокТовары.СуммаВознаграждения;
			ИтогоСуммаНДСВознаграждения = ИтогоСуммаНДСВознаграждения + ВыборкаСтрокТовары.СуммаНДСВознаграждения;
			НомерПП = НомерПП + 1;
			
		КонецЦикла;
		
		//ОбластьМакета = Макет.ПолучитьОбласть("СтрокаПокупательИтог");
		//ОбластьМакета.Параметры.Заполнить(ВыборкаПокупателей);
		//ТабДокумент.Вывести(ОбластьМакета);
		
	КонецЦикла;

	ОбластьМакета = Макет.ПолучитьОбласть("Итого");
	ОбластьМакета.Параметры.Всего = Итого;
	ОбластьМакета.Параметры.ВсегоСуммаВознаграждения = ИтогоСуммаВознаграждения;
	ОбластьМакета.Параметры.ВсегоСуммаНДСВознаграждения = ИтогоСуммаНДСВознаграждения;
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("СуммаПрописью");
	ОбластьМакета.Параметры.СуммаПрописью       = ОбщегоНазначения.СформироватьСуммуПрописью(Итого, Шапка.ВалютаДокумента);
	ОбластьМакета.Параметры.СуммаВознаграждения = "Сумма комиссионного вознаграждения составила " 
	                                            + ОбщегоНазначения.СформироватьСуммуПрописью(Шапка.СуммаВознаграждения, Шапка.ВалютаДокумента);
	//ОбластьМакета.Параметры.ИтоговаяСтрока      = "Всего наименований " + ВыборкаСтрокТовары.Количество() 
	ОбластьМакета.Параметры.ИтоговаяСтрока      = "Всего наименований " + (НомерПП-1) 
	                                            + ", на сумму " + ФормированиеПечатныхФорм.ФорматСумм(Итого, Шапка.ВалютаДокумента);
	ТабДокумент.Вывести(ОбластьМакета);

	ОбластьМакета = Макет.ПолучитьОбласть("Подписи");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	ТабДокумент.Вывести(ОбластьМакета);

	Возврат ТабДокумент;

КонецФункции // ПечатьОтчетаКомитенту()

//  Функция формирует табличиный документ как акт об оказании услуг
// на сумму вознаграждения
// 
Функция ПечатьАкта()

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ТекущийДокумент", ЭтотОбъект.Ссылка);
	Запрос.Текст ="
	|ВЫБРАТЬ
	|	Номер,
	|	Дата,
	|	ДоговорКонтрагента,
	|	Контрагент КАК Получатель,
	|	Организация КАК Поставщик,
	|	Организация,
	|	СуммаДокумента,
	|	ВалютаДокумента,
	|	СтавкаНДСВознаграждения,
	|	СуммаВознаграждения КАК Сумма
	|ИЗ
	|	Документ.ОтчетПринципалуОПродажах КАК ОтчетКомитентуОПродажах
	|
	|ГДЕ
	|	ОтчетКомитентуОПродажах.Ссылка = &ТекущийДокумент";
	Шапка = Запрос.Выполнить().Выбрать();

	Шапка.Следующий();

	ТабДокумент = Новый ТабличныйДокумент;
	ТабДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ОтчетКомитентуОПродажах_АктОбУслугах";
	Макет       = ПолучитьМакет("АктОбУслугах");

	ОбластьМакета = Макет.ПолучитьОбласть("Шапка");
	ОбластьМакета.Параметры.Заполнить(Шапка);
	
	//СведенияОбОрганизации    = КонтактнаяИнформация.СведенияОЮрФизЛице(Шапка.Организация, Шапка.Дата);
	//ПредставлениеОрганизации = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбОрганизации, "НаименованиеДляПечатныхФорм,");
	//
	//СведенияОКонтрагенте     = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Шапка.Получатель, Шапка.Дата);
	//ПредставлениеКонтрагента = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОКонтрагенте, "НаименованиеДляПечатныхФорм,");
	
	ОбластьМакета.Параметры.ПредставлениеПолучателя = ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(Контрагент, Дата), "ПолноеНаименование,ЮридическийАдрес,ИНН,КПП")+ Символы.ПС + Символы.ПС;
	
	ОписаниеОрг = ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(ПодразделениеОрганизации, Дата), "НаименованиеЗаказчика,");
	ОписаниеОрг = ОписаниеОрг + ", " + ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(Организация, Дата), "ЮридическийАдрес,ИНН,");
	ОписаниеКПП= ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(ПодразделениеОрганизации, Дата), "КПП,");
	ОписаниеОргФил= ФормированиеПечатныхФорм.ОписаниеОрганизации(КонтактнаяИнформация.СведенияОЮрФизЛице(ПодразделениеОрганизации, Дата), "ЮридическийАдрес,");
	
	ОбластьМакета.Параметры.ПредставлениеПоставщика = ОписаниеОрг+","+ОписаниеКПП+ Символы.ПС +"Адрес филиала: "+ОписаниеОргФил
	+ Символы.ПС + Символы.ПС;
	
	//ОбластьМакета.Параметры.ПредставлениеПоставщика = ПредставлениеОрганизации;
	//ОбластьМакета.Параметры.ПредставлениеПолучателя = ПредставлениеКонтрагента;

	ОбластьМакета.Параметры.ТекстЗаголовка      = РаботаСДиалогами.СформироватьЗаголовокДокумента(Шапка, "Акт об оказании услуг");
	ОбластьМакета.Параметры.ТекстОСуммеПрописью = 
		"Сумма комиссионного вознаграждения составила " 
		+ ОбщегоНазначения.СформироватьСуммуПрописью(Шапка.Сумма, Шапка.ВалютаДокумента)
		+ ", в том числе НДС " + Шапка.СтавкаНДСВознаграждения;

	ТабДокумент.Вывести(ОбластьМакета);

	Возврат ТабДокумент;

КонецФункции // ПечатьАкта() 

// Процедура осуществляет печать документа. Можно направить печать на 
// экран или принтер, а также распечатать необходимое количество копий.
//
//  Название макета печати передается в качестве параметра,
// по переданному названию находим имя макета в соответствии.
//
// Параметры:
//  НазваниеМакета - строка, название макета.
//
Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	
	Если ИмяМакета = "ОтчетКомитентуОПродажах" Тогда
		
		// Получить экземпляр документа на печать
		ТабДокумент = ПечатьОтчетаКомитенту();
	ИначеЕсли ИмяМакета = "АктОбОказанииУслуг" Тогда
		
		// Напечатаем акт об оказании услуг на сумму комиссионного вознаграждения
		ТабДокумент = ПечатьАкта();
	КонецЕсли;
	
	ФормированиеПечатныхФорм.НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, РаботаСДиалогами.СформироватьЗаголовокДокумента(ЭтотОбъект, ЭтотОбъект.Метаданные().Представление()), НепосредственнаяПечать);
	
КонецПроцедуры // Печать

#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Возвращаемое значение:
//  Структура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("ОтчетКомитентуОПродажах,АктОбОказанииУслуг","Отчет принципалу","Акт об оказании услуг");
	 //Возврат Новый Структура("ОтчетКомитентуОПродажах","Отчет принципалу");

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Выгружает результат запроса в табличную часть, добавляет ей необходимые колонки для проведения.
//
// Параметры: 
//  РезультатЗапросаПоТоварам - результат запроса по табличной части "Товары",
//  СтруктураШапкиДокумента   - выборка по результату запроса по шапке документа.
//
// Возвращаемое значение:
//  Сформированная таблица значений.
//
Функция ПодготовитьТаблицуТоваров(РезультатЗапросаПоТоварам, СтруктураШапкиДокумента)

	ТаблицаТоваров = РезультатЗапросаПоТоварам.Выгрузить();

	ТаблицаТоваров.Колонки.Добавить("ПодразделениеОрганизации");
	ТаблицаТоваров.Колонки.Добавить("КорПодразделениеОрганизации");

	ТаблицаТоваров.ЗаполнитьЗначения(СтруктураШапкиДокумента.ПодразделениеОрганизации, "ПодразделениеОрганизации");
	ТаблицаТоваров.ЗаполнитьЗначения(СтруктураШапкиДокумента.ПодразделениеОрганизации, "КорПодразделениеОрганизации");

	ТаблицаТоваров.Колонки.Добавить("СуммаБезНДС", ОбщегоНазначения.ПолучитьОписаниеТиповЧисла(15,2));

	Для каждого СтрокаТаблицы Из ТаблицаТоваров Цикл

		СтрокаТаблицы.СуммаБезНДС = СтрокаТаблицы.Сумма - 
								  ?(УчитыватьНДС И СуммаВключаетНДС, СтрокаТаблицы.НДС, 0);

	КонецЦикла;

	Возврат ТаблицаТоваров;

КонецФункции // ПодготовитьТаблицуТоваров()

// Проверяет правильность заполнения шапки документа.
// Если какой-то из реквизитов шапки, влияющий на проведение не заполнен или
// заполнен не корректно, то выставляется флаг отказа в проведении.
// Проверяется также правильность заполнения реквизитов ссылочных полей документа.
// Проверка выполняется по объекту и по выборке из результата запроса по шапке.
//
// Параметры: 
//  СтруктураШапкиДокумента - выборка из результата запроса по шапке документа,
//  Отказ                   - флаг отказа в проведении,
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура("Организация, ВалютаДокумента, Контрагент, ДоговорКонтрагента, КратностьВзаиморасчетов");

	// Теперь вызовем общую процедуру проверки.
	ОбщегоНазначения.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Проверяет правильность заполнения строк табличной части "Товары".
//
// Параметры:
// Параметры: 
//  ТаблицаПоТоварам        - таблица значений, содержащая данные для проведения и проверки ТЧ Товары
//  СтруктураШапкиДокумента - выборка из результата запроса по шапке документа,
//  Отказ                   - флаг отказа в проведении.
//  Заголовок               - строка, заголовок сообщения об ошибке проведения.
//
Процедура ПроверитьЗаполнениеТабличнойЧастиТовары(ТаблицаПоТоварам, СтруктураШапкиДокумента, Отказ, Заголовок)

	// Укажем, что надо проверить:
	СтруктураОбязательныхПолей = Новый Структура(); //"Номенклатура, Количество, Сумма");

	// Теперь вызовем общую процедуру проверки.
	ОбщегоНазначения.ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "Товары", СтруктураОбязательныхПолей, Отказ, Заголовок);

	// Здесь услуг быть не должно.
	//УправлениеЗапасами.ПроверитьЧтоНетУслуг(ЭтотОбъект, "Товары", ТаблицаПоТоварам, Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеТабличнойЧастиТовары()

// По результату запроса по шапке документа формируем движения по регистрам.
//
// Параметры: 
//  РежимПроведения           - режим проведения документа (оперативный или неоперативный),
//  СтруктураШапкиДокумента   - выборка из результата запроса по шапке документа,
//  ТаблицаПоТоварам          - таблица значений, содержащая данные для проведения и проверки ТЧ Товары
//  Отказ                     - флаг отказа в проведении,
//  Заголовок                 - строка, заголовок сообщения об ошибке проведения.
//
Процедура ДвиженияПоРегистрам(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоУслугам, Отказ, Заголовок);

	ДатаДока   = СтруктураШапкиДокумента.Дата;
	
	ТаблицаВыручки = ТаблицаПоУслугам.Скопировать();
	ТаблицаВыручки.Свернуть("AU","Сумма,СуммаБезНДС,НДС,СуммаВал,СуммаБезНДСВал,НДСВал");
	
	//Изменила РГ-Софт - Бакшеева Анна - 2014-02-25 ->
	//добавлен регистр, объединяющий регистры: "Продажи", "Выручка_SB" 
	//Продажи = Движения.Продажи;
	
	ВалютаSLB = Справочники.Валюты.НайтиПоНаименованию("SLB");
	КурсSLB = ОбщегоНазначения.ПолучитьКурсВалюты(ВалютаSLB,СтруктураШапкиДокумента.Дата).Курс;
	
	Продажи = Движения.ПродажиВыручка_SB;
	
	Для Каждого СтрокаТЧ Из ТаблицаВыручки Цикл
		//Запись = Продажи.Добавить();
		//Запись.AU = СтрокаТЧ.AU; 
		//Запись.Валюта = СтруктураШапкиДокумента.ВалютаДокумента;
		//Запись.ДоговорКонтрагента = СтруктураШапкиДокумента.ДоговорКонтрагента;
		//Запись.ДокументРеализации = СтруктураШапкиДокумента.Ссылка;
		//Запись.ИнвойсинговыйЦентр = Справочники.ИнвойсинговыеЦентры.ПустаяСсылка();
		//ВалютаSLB = Справочники.Валюты.НайтиПоНаименованию("SLB");
		//КурсSLB = ОбщегоНазначения.ПолучитьКурсВалюты(ВалютаSLB,СтруктураШапкиДокумента.Дата).Курс;
		//Запись.Курс = КурсSLB;
		//Запись.НалоговыйПериод = СтруктураШапкиДокумента.Дата;
		//Запись.Номенклатура = СтруктураШапкиДокумента.УслугаПоВознаграждению;
		//Запись.НоменклатураНаименованиеENG = СтруктураШапкиДокумента.УслугаПоВознаграждению.НаименованиеENG;
		//Запись.Период = СтруктураШапкиДокумента.Дата;
		//Запись.ПодразделениеОрганизации = СтруктураШапкиДокумента.ПодразделениеОрганизации;
		//Запись.СтавкаНДС = СтруктураШапкиДокумента.СтавкаНДСВознаграждения;
		//Запись.СуммаRUR = СтрокаТЧ.СуммаБезНДС;
		//Запись.СуммаUSD = СтрокаТЧ.СуммаБезНДС/КурсSLB;
		//Запись.СуммаНДСRUR = СтрокаТЧ.НДС;
		//Запись.СуммаНДСUSD = СтрокаТЧ.НДС/КурсSLB;
		//Запись.Тип = "AGE";
		
		Запись = Продажи.Добавить();
		// { RGS LFedotova 25.09.2018 20:44:51 - вопрос SLI-0007666
		//Запись.Период 					= СтруктураШапкиДокумента.Дата;
		//// измерения
		//Запись.НалоговыйПериод			= СтруктураШапкиДокумента.Дата;;
		Запись.Период 					= СтруктураШапкиДокумента.ДатаПроведения;
		// измерения
		Запись.НалоговыйПериод			= СтруктураШапкиДокумента.НалоговыйПериод;
		// } RGS LFedotova 25.09.2018 20:45:04 - вопрос SLI-0007666 
		Запись.ИнвойсинговыйЦентр 		= Справочники.ИнвойсинговыеЦентры.ПустаяСсылка(); 
		Запись.ДоговорКонтрагента 		= СтруктураШапкиДокумента.ДоговорКонтрагента;
		Запись.ПодразделениеОрганизации = СтруктураШапкиДокумента.ПодразделениеОрганизации;
		Запись.ВалютаДокумента			= СтруктураШапкиДокумента.ВалютаДокумента;
		Запись.ДокументРеализации 		= СтруктураШапкиДокумента.Ссылка;
		Запись.Тип 						= "AGE";
		Запись.AU						= СтрокаТЧ.AU;
		// ресурсы
		Запись.СуммаБезНДСRUR 	= СтрокаТЧ.СуммаБезНДС;
		Запись.СуммаБезНДСUSD 	= СтрокаТЧ.СуммаБезНДС/КурсSLB;
		Запись.СуммаНДСRUR		= СтрокаТЧ.НДС;
		Запись.СуммаНДСUSD 		= СтрокаТЧ.НДС/КурсSLB;
		Запись.СуммаБезНДС 		= СтрокаТЧ.СуммаБезНДСВал;
		Запись.СуммаНДС 		= СтрокаТЧ.НДСВал;
		// реквизиты
		Запись.Номенклатура					= СтруктураШапкиДокумента.УслугаПоВознаграждению;
		Запись.НоменклатураНаименование 	= СтруктураШапкиДокумента.УслугаПоВознаграждению.НаименованиеПолное;
		Запись.НоменклатураНаименованиеENG 	= СтруктураШапкиДокумента.УслугаПоВознаграждению.НаименованиеENG;
		Запись.СтавкаНДС 					= СтруктураШапкиДокумента.СтавкаНДСВознаграждения;
		Запись.Курс 						= КурсSLB;
		//<-
		
		Запись = Движения.ВзаиморасчетыСПокупателями.Добавить();
		Запись.ВидДвижения = ВидДвиженияНакопления.Приход;
		Запись.ДоговорКонтрагента = СтруктураШапкиДокумента.ДоговорКонтрагента;
		//Запись.ИнвойсинговыйЦентр = Справочники.ИнвойсинговыеЦентры.ПустаяСсылка();
		Запись.КостЦентр 		  = СтрокаТЧ.AU;
		Запись.Период 			  = СтруктураШапкиДокумента.Дата;
		Запись.ПодразделениеОрганизации = СтруктураШапкиДокумента.ПодразделениеОрганизации;
		Запись.Сделка 			   = СтруктураШапкиДокумента.Ссылка;
		Запись.СуммаВзаиморасчетов = СтрокаТЧ.СуммаБезНДСВал + СтрокаТЧ.НДСВал;
		Запись.СуммаРегл = СтрокаТЧ.СуммаБезНДС + СтрокаТЧ.НДС;
		Запись.СуммаУпр = (СтрокаТЧ.СуммаБезНДС + СтрокаТЧ.НДС)/КурсSLB;
		
	КонецЦикла;
	Продажи.Записать();
	
	ДвиженияРегистровПодсистемыНДС(СтруктураШапкиДокумента, ТаблицаПоУслугам, Отказ);

КонецПроцедуры // ДвиженияПоРегистрам()

// Процедура вызывается из тела процедуры ДвиженияПоРегистрам
// Формирует движения по регистрам подсистемы учета НДС "НДСПокупки" и "НДСПродажи"
Процедура ДвиженияРегистровПодсистемыНДС(СтруктураШапкиДокумента, ТаблицаВыручки, Отказ)

	ТаблицаВыручкиДляНДС = ТаблицаВыручки.Скопировать();
	ТаблицаВыручкиДляНДС.ЗаполнитьЗначения(СтруктураШапкиДокумента.УслугаПоВознаграждению,"Ценность,Номенклатура");
	ТаблицаВыручкиДляНДС.ЗаполнитьЗначения(Перечисления.ВидыЦенностей.ПосредническиеУслуги,"ВидЦенности");
	ТаблицаВыручкиДляНДС.ЗаполнитьЗначения(Истина,"Услуга");
	ТаблицаВыручкиДляНДС.Свернуть("ВидЦенности, Ценность, СчетУчетаЦенности, СтавкаНДС, Номенклатура, Услуга",
	"Сумма,СуммаБезНДС,НДС,СуммаВал,СуммаБезНДСВал,НДСВал,Количество");
	
	УчетНДС.СформироватьДвиженияПоРегиструНДСНачисленный_ОтражениеРеализации(СтруктураШапкиДокумента, ТаблицаВыручкиДляНДС, Движения, Отказ);
	
КонецПроцедуры // ДвиженияРегистровПодсистемыНДС()

// Процедура формирует структуру шапки документа и дополнительных полей.
//
Процедура ПодготовитьСтруктуруШапкиДокумента(Заголовок, СтруктураШапкиДокумента, Отказ) Экспорт
	
	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента   = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	// Заполним по шапке документа дерево параметров, нужных при проведении.
	ДеревоПолейЗапросаПоШапке = ОбщегоНазначения.СформироватьДеревоПолейЗапросаПоШапке();
	ОбщегоНазначения.ДобавитьСтрокуВДеревоПолейЗапросаПоШапке(ДеревоПолейЗапросаПоШапке, "ДоговорыКонтрагентов", "Организация", "ДоговорОрганизация");

	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
	СтруктураШапкиДокумента = УправлениеЗапасами.СформироватьЗапросПоДеревуПолей(ЭтотОбъект, ДеревоПолейЗапросаПоШапке, СтруктураШапкиДокумента, мВалютаРегламентированногоУчета);

	//Пока не добавили реквизиты в шапку
	Если не СтруктураШапкиДокумента.Свойство("СуммаВключаетНДС") тогда
		СтруктураШапкиДокумента.Вставить("СуммаВключаетНДС",Истина);
	КонецЕсли;

	Если не СтруктураШапкиДокумента.Свойство("УчитыватьНДС") тогда
		СтруктураШапкиДокумента.Вставить("УчитыватьНДС",Истина);
	КонецЕсли;

	СтруктураПолейУчетнойПолитикиНУ = Новый Структура("СложныйУчетНДС, УпрощенныйУчетНДС");
	ОбщегоНазначения.ДополнитьПоложениямиУчетнойПолитики(СтруктураШапкиДокумента, СтруктураШапкиДокумента.Дата, Отказ, СтруктураШапкиДокумента.Организация, "Нал", СтруктураПолейУчетнойПолитикиНУ);
	
	// { RGS LFedotova 25.09.2018 20:41:57 - вопрос SLI-0007666
	//СтруктураШапкиДокумента.Вставить("НалоговыйПериод", Дата);
	//СтруктураШапкиДокумента.Вставить("ДатаПроведения", Дата);
	СтруктураШапкиДокумента.Вставить("НалоговыйПериод", ?(ЗначениеЗаполнено(НалоговыйПериод),НалоговыйПериод,Дата));
	СтруктураШапкиДокумента.Вставить("ДатаПроведения", ?(ЗначениеЗаполнено(ДатаПроведения),ДатаПроведения,Дата));
	// } RGS LFedotova 25.09.2018 20:42:04 - вопрос SLI-0007666 
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура - обработчик события "ОбработкаЗаполнения".
//
Процедура ОбработкаЗаполнения(Основание)


	Если ТипЗнч(Основание) = Тип("ДокументСсылка.РеализацияТоваровУслуг") Тогда

		ЗаполнитьТабЧастьПоОснованию(Основание);
		
	КонецЕсли;

КонецПроцедуры // ОбработкаЗаполнения()

// Процедура вызывается перед записью документа 
//
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// Посчитать суммы документа и записать ее в соответствующий реквизит шапки для показа в журналах
	СуммаДокумента = ОбщегоНазначения.ПолучитьСуммуДокументаСНДС(ЭтотОбъект, "Товары");
	СуммаВознаграждения = Товары.Итог("СуммаВознаграждения")+?(СуммаВключаетНДС,0,Товары.Итог("СуммаНДСВознаграждения"));
	
	УчетНДС.СинхронизацияПометкиНаУдалениеУСчетаФактуры(ЭтотОбъект);
	
КонецПроцедуры // ПередЗаписью()

Процедура ПриЗаписи(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	//УчетНДС.ПроверитьСоответствиеРеквизитовСчетаФактуры(ЭтотОбъект); //хорошо бы
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Перем СтруктураШапкиДокумента;
	
	// Заголовок для сообщений об ошибках проведения.
	Заголовок = "Проведение документа """ + СокрЛП(Ссылка) + """: ";
	
	ПодготовитьСтруктуруШапкиДокумента(Заголовок, СтруктураШапкиДокумента, Отказ);
	
	// Проверим правильность заполнения шапки документа
	ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	// Получим необходимые данные для проведения и проверки заполенения данные по табличной части "Товары".
	СтруктураПолей = Новый Структура();
	СтруктураПолей.Вставить("Номенклатура", "Номенклатура");
	СтруктураПолей.Вставить("Услуга"      , "Номенклатура.Услуга");
	СтруктураПолей.Вставить("AU"          , "КостЦентр");
	СтруктураПолей.Вставить("Количество"  , "Количество");
	СтруктураПолей.Вставить("СтавкаНДС"   , "Ссылка.СтавкаНДСВознаграждения");
	СтруктураПолей.Вставить("Сумма"       , "СуммаВознаграждения");
	СтруктураПолей.Вставить("НДС"         , "СуммаНДСВознаграждения");
	
	//Поля, необходимые для списания регистра реализованных товаров	
	СтруктураПолей.Вставить("Количество"  			, "Количество");
	СтруктураПолей.Вставить("СуммаПоступления" 		, "СуммаПоступления");
	СтруктураПолей.Вставить("Выручка"  				, "Сумма");
	//
	СтруктураПолей.Вставить("Покупатель"  			, "Покупатель");
	СтруктураПолей.Вставить("ДатаРеализации"		, "ДатаРеализации");
	//
	
	РезультатЗапросаПоУслугам = УправлениеЗапасами.СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "Товары", СтруктураПолей);
	
	// Подготовим таблицу товаров для проведения.
	ТаблицаПоУслугам = ПодготовитьТаблицуТоваров(РезультатЗапросаПоУслугам, СтруктураШапкиДокумента);
	
	// Проверить заполнение ТЧ "Товары".
	ПроверитьЗаполнениеТабличнойЧастиТовары(ТаблицаПоУслугам, СтруктураШапкиДокумента, Отказ, Заголовок);
	
	УправлениеВзаиморасчетами.ПодготовкаТаблицыЗначенийДляЦелейПриобретенияИРеализации(ТаблицаПоУслугам, СтруктураШапкиДокумента, Истина);
	
	// Движения по документу
	Если Не Отказ Тогда
		ДвиженияПоРегистрам(РежимПроведения, СтруктураШапкиДокумента, ТаблицаПоУслугам, Отказ, Заголовок);
	КонецЕсли;
	
КонецПроцедуры // ОбработкаПроведения()

Процедура ОбработкаУдаленияПроведения(Отказ)
		
	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ, , Ложь);
	
	//УчетНДС.УстановкаПроведенияУСчетаФактуры(Ссылка, "СчетФактураВыданный", Ложь);

КонецПроцедуры

// Рассчитывает комиссионное вознаграждение в строке табличной части документа
//
// Параметры:
//  СтрокаТабличнойЧасти - строка табличной части документа,
//
Процедура РассчитатьКомиссионноеВознаграждение(СтрокаТабличнойЧасти) Экспорт

	Если СпособРасчетаКомиссионногоВознаграждения
		 = Перечисления.СпособыРасчетаКомиссионногоВознаграждения.НеРассчитывается Тогда

	//ИначеЕсли СпособРасчетаКомиссионногоВознаграждения
	//	 = Перечисления.СпособыРасчетаКомиссионногоВознаграждения.ПроцентОтРазностиСуммПродажиИПоступления Тогда

	//	СтрокаТабличнойЧасти.СуммаВознаграждения = ПроцентКомиссионногоВознаграждения / 100
	//		* (СтрокаТабличнойЧасти.Сумма + ?(СуммаВключаетНДС, 0, СтрокаТабличнойЧасти.СуммаНДС) - СтрокаТабличнойЧасти.СуммаПоступления);

	ИначеЕсли СпособРасчетаКомиссионногоВознаграждения
		 = Перечисления.СпособыРасчетаКомиссионногоВознаграждения.ПроцентОтСуммыПродажи Тогда
		 
		 //изменила Федотова Л., РГ-Софт, 17.12.12, вопрос №SLI-0003093
		 //СтрокаТабличнойЧасти.СуммаВознаграждения = ПроцентКомиссионногоВознаграждения / 100
		 //	* (СтрокаТабличнойЧасти.Сумма + ?(СуммаВключаетНДС, 0, СтрокаТабличнойЧасти.СуммаНДС));
		 
		 //изменила Федотова Л., РГ-Софт, 17.12.12, вопрос №SLI-0003093
		 //СтрокаТабличнойЧасти.СуммаВознаграждения = ПроцентКомиссионногоВознаграждения / 100
		 //	* (СтрокаТабличнойЧасти.Сумма - ?(СуммаВключаетНДС, СтрокаТабличнойЧасти.СуммаНДС,0));
		 
		 //изменила Федотова Л., РГ-Софт, 20.12.12, вопрос №SLI-0003104
		 СтрокаТабличнойЧасти.СуммаВознаграждения = ПроцентКомиссионногоВознаграждения / 100
		 * (СтрокаТабличнойЧасти.Сумма + ?(СуммаВключаетНДС, 0, СтрокаТабличнойЧасти.СуммаНДС));

	Иначе
		СтрокаТабличнойЧасти.СуммаВознаграждения = 0;
	КонецЕсли;

	//закомментировала Федотова Л., РГ-Софт, 17.12.12, вопрос №SLI-0003093
	//СтрокаТабличнойЧасти.СуммаВознаграждения = ОбработкаТабличныхЧастей.ПересчитатьЦенуПриИзмененииФлаговНалогов(СтрокаТабличнойЧасти.СуммаВознаграждения, Неопределено, Истина, УчитыватьНДС, 
	//										СуммаВключаетНДС, УчетНДС.ПолучитьСтавкуНДС(СтавкаНДСВознаграждения));
	
	//изменила Федотова Л., РГ-Софт, 17.12.12, вопрос №SLI-0003093
	//СтрокаТабличнойЧасти.СуммаНДСВознаграждения = ОбщегоНазначения.РассчитатьСуммуНДС(СтрокаТабличнойЧасти.СуммаВознаграждения,
	//		УчитыватьНДС, СуммаВключаетНДС, УчетНДС.ПолучитьСтавкуНДС(СтавкаНДСВознаграждения));
	СтрокаТабличнойЧасти.СуммаНДСВознаграждения = ОбщегоНазначения.РассчитатьСуммуНДС(СтрокаТабличнойЧасти.СуммаВознаграждения,
	        УчитыватьНДС, Ложь, УчетНДС.ПолучитьСтавкуНДС(СтавкаНДСВознаграждения));
	
КонецПроцедуры // РассчитатьКомиссионноеВознаграждение()

Процедура ЗаполнитьТабЧастьПоОснованию(Основание) Экспорт
	
	Если НЕ Основание.ВидОперации = Перечисления.ВидыОперацийРеализацияТоваров.РеализацияАгент Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Вид операции документа-основания должен быть ""Реализация, агент""!");
		Возврат;
	КонецЕсли;
	// Заполним реквизиты из стандартного набора по документу основанию.
	//ОбщегоНазначения.ЗаполнитьШапкуДокументаПоОснованию(ЭтотОбъект, Основание);
	//Добавила Федотова Л., РГ-Софт, 18.12.12, вопрос №SLI-0003093 ->
	УчитыватьНДС = Основание.УчитыватьНДС;   
	СуммаВключаетНДС = Основание.СуммаВключаетНДС;   
	ВалютаДокумента = Основание.ВалютаДокумента;   
	КурсВзаиморасчетов = Основание.КурсВзаиморасчетов;   
	КратностьВзаиморасчетов = Основание.КратностьВзаиморасчетов;   
	ПодразделениеОрганизации = Основание.ПодразделениеОрганизации;   
	Руководитель = Основание.Руководитель;   
	ГлавныйБухгалтер = Основание.ГлавныйБухгалтер;   
	//<-
	Для каждого Строка Из Основание.Товары Цикл
		НоваяСтрока = Товары.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока,Строка);
		НоваяСтрока.Покупатель = Основание.Контрагент;
		НоваяСтрока.ДатаРеализации = Основание.Дата;
		РассчитатьКомиссионноеВознаграждение(НоваяСтрока);
	КонецЦикла; 
	Для каждого Строка Из Основание.Услуги Цикл
		НоваяСтрока = Товары.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока,Строка);
		НоваяСтрока.Покупатель = Основание.Контрагент;
		НоваяСтрока.ДатаРеализации = Основание.Дата;
		РассчитатьКомиссионноеВознаграждение(НоваяСтрока);
	КонецЦикла; 
	
КонецПроцедуры

мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();

мЗаконодательство2006 = Дата >= '20060101000000';

