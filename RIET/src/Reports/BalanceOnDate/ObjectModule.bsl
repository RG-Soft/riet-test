#Если Клиент Тогда
	
// Настройка периода
Перем НП Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ 
// 

Процедура СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок = Ложь, ВысотаЗаголовка = 0, ТолькоЗаголовок = Ложь) Экспорт

	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "ДатаНач", ОбщийОтчет.ДатаНач);
	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "ДатаКон", ОбщийОтчет.ДатаКон);
	Коэффициент = ?(НеУчитыватьПереоценкиВалют,1,0);
	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "Коэффициент", Коэффициент);
	ОбщийОтчет.ВыводитьДополнительныеПоляВОтдельнойКолонке = Истина;
	
	ОбщийОтчет.СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок, ВысотаЗаголовка, ТолькоЗаголовок);

КонецПроцедуры // СформироватьОтчет()

// Процедура - заполняет начальные настройки отчета
//
Процедура ЗаполнитьНачальныеНастройки() Экспорт
	
	ПостроительОтчета = ОбщийОтчет.ПостроительОтчета;
	ОбщийОтчет.ВыводитьДополнительныеПоляВОтдельнойКолонке = Истина;
	
	Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
	        |	СчетНаОплатуПокупателю.Ссылка КАК СчетНаОплату,
	        |	СчетФактураВыданный.Ссылка КАК СчетФактура,
	        |	ВзаиморасчетыСПокупателямиОстатки.ДоговорКонтрагента КАК ДоговорКонтрагента,
	        |	ВзаиморасчетыСПокупателямиОстатки.ДоговорКонтрагента.Владелец КАК Контрагент,
	        |	ВзаиморасчетыСПокупателямиОстатки.ПодразделениеОрганизации КАК Подразделение,
	        |	ВзаиморасчетыСПокупателямиОстатки.Сделка,
	        |	ВзаиморасчетыСПокупателямиОстатки.КостЦентр,
	        |	ВзаиморасчетыСПокупателямиОстатки.СуммаВзаиморасчетовОстаток КАК СуммаВзаиморасчетов,
	        |	ВзаиморасчетыСПокупателямиОстатки.СуммаУпрОстаток КАК СуммаUSD,
	        |	ВзаиморасчетыСПокупателямиОстатки.СуммаРеглОстаток КАК СуммаРуб,
	        |	ВзаиморасчетыСПокупателямиОстатки.Сделка.ИнвойсинговыйЦентр КАК  ИнвойсинговыйЦентр
	        |ПОМЕСТИТЬ ИтоговаяТаблица
	        |ИЗ
	        |	РегистрНакопления.ВзаиморасчетыСПокупателями.Остатки(&ДатаКон, ) КАК ВзаиморасчетыСПокупателямиОстатки
	        |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.СчетФактураВыданный КАК СчетФактураВыданный
	        |		ПО ВзаиморасчетыСПокупателямиОстатки.Сделка = СчетФактураВыданный.ДокументОснование
	        |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.СчетНаОплатуПокупателю КАК СчетНаОплатуПокупателю
	        |		ПО ВзаиморасчетыСПокупателямиОстатки.Сделка = СчетНаОплатуПокупателю.ДокументОснование
	        |ГДЕ
	        |	ВзаиморасчетыСПокупателямиОстатки.Сделка <> НЕОПРЕДЕЛЕНО
	        |	И ВЫБОР
	        |			КОГДА НЕ СчетНаОплатуПокупателю.Ссылка ЕСТЬ NULL 
	        |				ТОГДА НЕ СчетНаОплатуПокупателю.ПометкаУдаления
	        |			ИНАЧЕ ИСТИНА
	        |		КОНЕЦ
	        |	И ВЫБОР
	        |			КОГДА НЕ СчетФактураВыданный.Ссылка ЕСТЬ NULL 
	        |				ТОГДА НЕ СчетФактураВыданный.ПометкаУдаления
	        |			ИНАЧЕ ИСТИНА
	        |		КОНЕЦ
	        |{ГДЕ
	        |	СчетНаОплатуПокупателю.Ссылка.* КАК СчетНаОплату,
	        |	СчетФактураВыданный.Ссылка.* КАК СчетФактура,
	        |	ВзаиморасчетыСПокупателямиОстатки.ДоговорКонтрагента.*,
	        |	ВзаиморасчетыСПокупателямиОстатки.ДоговорКонтрагента.Владелец.* КАК Контрагент,
	        |	ВзаиморасчетыСПокупателямиОстатки.ПодразделениеОрганизации.* КАК Подразделение,
	        |	ВзаиморасчетыСПокупателямиОстатки.Сделка.*,
	        |	ВзаиморасчетыСПокупателямиОстатки.КостЦентр.*,
	        |	ВзаиморасчетыСПокупателямиОстатки.Сделка.ИнвойсинговыйЦентр.*}
	        |{УПОРЯДОЧИТЬ ПО
	        |	СчетНаОплату.*,
	        |	СчетФактура.*,
	        |	ДоговорКонтрагента.*,
	        |	Контрагент.*,
	        |	Подразделение.*,
	        |	Сделка.*,
	        |	КостЦентр.*,
	        |	ИнвойсинговыйЦентр.*}
	        |{ИТОГИ ПО
	        |	Контрагент.*,
	        |	ДоговорКонтрагента.*,
	        |	Подразделение.*,
	        |	Сделка.*,
	        |	КостЦентр.*,
	        |	СчетФактура.*,
	        |	СчетНаОплату.*,
	        |	ИнвойсинговыйЦентр.*}
	        |;
	        |
	        |////////////////////////////////////////////////////////////////////////////////
	        |ВЫБРАТЬ
	        |	ВзаиморасчетыСПокупателями.Сделка,
	        |	ВзаиморасчетыСПокупателями.ДоговорКонтрагента,
	        |	СУММА(ВзаиморасчетыСПокупателями.СуммаВзаиморасчетов) КАК СуммаВзаиморасчетов,
	        |	СУММА(ВзаиморасчетыСПокупателями.СуммаУпр) КАК СуммаУпр,
	        |	СУММА(ВзаиморасчетыСПокупателями.СуммаРегл) КАК СуммаРегл,
	        |	ВзаиморасчетыСПокупателями.Сделка.ИнвойсинговыйЦентр КАК ИнвойсинговыйЦентр,
	        |	ВзаиморасчетыСПокупателями.КостЦентр
	        |ПОМЕСТИТЬ Переоценки
	        |ИЗ
	        |	ИтоговаяТаблица КАК ИтоговаяТаблица
	        |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрНакопления.ВзаиморасчетыСПокупателями КАК ВзаиморасчетыСПокупателями
	        |		ПО ИтоговаяТаблица.ДоговорКонтрагента = ВзаиморасчетыСПокупателями.ДоговорКонтрагента
	        |			И ИтоговаяТаблица.Сделка = ВзаиморасчетыСПокупателями.Сделка
	        |			И ИтоговаяТаблица.ИнвойсинговыйЦентр = ВзаиморасчетыСПокупателями.Сделка.ИнвойсинговыйЦентр
	        |			И ИтоговаяТаблица.КостЦентр = ВзаиморасчетыСПокупателями.КостЦентр
	        |ГДЕ
	        |	ВзаиморасчетыСПокупателями.Регистратор ССЫЛКА Документ.ПереоценкаВалютыВРегистре
	        |
	        |СГРУППИРОВАТЬ ПО
	        |	ВзаиморасчетыСПокупателями.Сделка,
	        |	ВзаиморасчетыСПокупателями.ДоговорКонтрагента,
	        |	ВзаиморасчетыСПокупателями.Сделка.ИнвойсинговыйЦентр,
	        |	ВзаиморасчетыСПокупателями.КостЦентр
	        |;
	        |
	        |////////////////////////////////////////////////////////////////////////////////
	        |ВЫБРАТЬ
	        |	ИтоговаяТаблица.СчетНаОплату,
	        |	ИтоговаяТаблица.СчетФактура,
	        |	ИтоговаяТаблица.ДоговорКонтрагента,
	        |	ИтоговаяТаблица.Контрагент,
	        |	ИтоговаяТаблица.Подразделение,
	        |	ИтоговаяТаблица.Сделка,
	        |	ИтоговаяТаблица.КостЦентр,
	        |	ИтоговаяТаблица.СуммаВзаиморасчетов - &Коэффициент * ЕСТЬNULL(Переоценки.СуммаВзаиморасчетов, 0) КАК СуммаВзаиморасчетов,
	        |	ИтоговаяТаблица.СуммаUSD - &Коэффициент * ЕСТЬNULL(Переоценки.СуммаУпр, 0) КАК СуммаUSD,
	        |	ИтоговаяТаблица.СуммаРуб - &Коэффициент * ЕСТЬNULL(Переоценки.СуммаРегл, 0) КАК СуммаРуб,
	        |	ИтоговаяТаблица.ИнвойсинговыйЦентр
	        |{ВЫБРАТЬ
	        |	СчетНаОплату.*,
	        |	СчетФактура.*,
	        |	ДоговорКонтрагента.*,
	        |	Контрагент.*,
	        |	Подразделение.*,
	        |	Сделка.*,
	        |	КостЦентр.*,
	        |	ИнвойсинговыйЦентр.*}
	        |ИЗ
	        |	ИтоговаяТаблица КАК ИтоговаяТаблица
	        |		ЛЕВОЕ СОЕДИНЕНИЕ Переоценки КАК Переоценки
	        |		ПО ИтоговаяТаблица.ДоговорКонтрагента = Переоценки.ДоговорКонтрагента
	        |			И ИтоговаяТаблица.Сделка = Переоценки.Сделка
	        |			И ИтоговаяТаблица.ИнвойсинговыйЦентр = Переоценки.ИнвойсинговыйЦентр
	        |			И ИтоговаяТаблица.КостЦентр = Переоценки.КостЦентр
	        |{ГДЕ
	        |	ИтоговаяТаблица.СчетНаОплату.*,
	        |	ИтоговаяТаблица.СчетФактура.*,
	        |	ИтоговаяТаблица.ДоговорКонтрагента.*,
	        |	ИтоговаяТаблица.Контрагент.*,
	        |	ИтоговаяТаблица.Подразделение.*,
	        |	ИтоговаяТаблица.Сделка.*,
	        |	ИтоговаяТаблица.КостЦентр.*,
	        |	ИтоговаяТаблица.ИнвойсинговыйЦентр.*}
	        |{УПОРЯДОЧИТЬ ПО
	        |	СчетНаОплату.*,
	        |	СчетФактура.*,
	        |	ДоговорКонтрагента.*,
	        |	Контрагент.*,
	        |	Подразделение.*,
	        |	Сделка.*,
	        |	КостЦентр.*,
	        |	ИнвойсинговыйЦентр.*}
	        |ИТОГИ
	        |	СУММА(СуммаВзаиморасчетов),
	        |	СУММА(СуммаUSD),
	        |	СУММА(СуммаРуб)
	        |ПО
	        |	ОБЩИЕ
	        |{ИТОГИ ПО
	        |	СчетНаОплату.*,
	        |	СчетФактура.*,
	        |	ДоговорКонтрагента.*,
	        |	Контрагент.*,
	        |	Подразделение.*,
	        |	Сделка.*,
	        |	КостЦентр.*,
	        |	ИнвойсинговыйЦентр.*}";	
	
	СтруктураПредставлениеПолей = Новый Структура;
	СтруктураПредставлениеПолей.Вставить( "КостЦентр", "Accounting unit");
	СтруктураПредставлениеПолей.Вставить( "Сделка", "Документ");
    СтруктураПредставлениеПолей.Вставить( "ДоговорКонтрагента", "Договор контрагента");
	СтруктураПредставлениеПолей.Вставить( "СчетФактура", "Счет фактура");
	СтруктураПредставлениеПолей.Вставить( "СчетНаОплату", "Счет на оплату");
    СтруктураПредставлениеПолей.Вставить( "ИнвойсинговыйЦентр", "Инвойсинговый центр");


	
	ПостроительОтчета.Текст = Текст;
	
	УправлениеОтчетами.ЗаполнитьПредставленияПолей(СтруктураПредставлениеПолей, ПостроительОтчета);
	
	УправлениеОтчетами.ОчиститьДополнительныеПоляПостроителя(ПостроительОтчета);
	
	ОбщийОтчет.ЗаполнитьПоказатели( "СуммаВзаиморасчетов",   "Сумма (в валюте)",    Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "СуммаРуб",   "Сумма (в рублях)",    Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "СуммаUSD",   "Сумма (в валюте USD)",    Истина, "ЧЦ=15; ЧДЦ=2");
	
	МассивОтбора = Новый Массив;
	МассивОтбора.Добавить("Контрагент");
	МассивОтбора.Добавить("СчетНаОплату");
	МассивОтбора.Добавить("СчетФактура");
	МассивОтбора.Добавить("ДоговорКонтрагента");
	МассивОтбора.Добавить("КостЦентр");
	МассивОтбора.Добавить("Подразделение");
    МассивОтбора.Добавить("ИнвойсинговыйЦентр");

	ПостроительОтчета.ИзмеренияСтроки.Добавить("Контрагент");
	ПостроительОтчета.ИзмеренияСтроки.Добавить("ДоговорКонтрагента");
	
	ПостроительОтчета.ВыбранныеПоля.Очистить();
	ПостроительОтчета.ВыбранныеПоля.Добавить("Сделка");
	ПостроительОтчета.ВыбранныеПоля.Добавить("Подразделение");

    ОбщийОтчет.ВыводитьПоказателиВСтроку=Истина;
	УправлениеОтчетами.ЗаполнитьОтбор(МассивОтбора, ПостроительОтчета);
	
КонецПроцедуры // ЗаполнитьНачальныеНастройки()

// Читает свойство Построитель отчета
//
// Параметры
//	Нет
//
Функция ПолучитьПостроительОтчета() Экспорт

	Возврат ОбщийОтчет.ПолучитьПостроительОтчета();

КонецФункции // ПолучитьПостроительОтчета()

// Настраивает отчет по переданной структуре параметров
//
// Параметры:
//	Нет.
//
Процедура Настроить(Параметры) Экспорт

	ОбщийОтчет.Настроить(Параметры, ЭтотОбъект);

КонецПроцедуры // Настроить()

// Возвращает основную форму отчета, связанную с данным экземпляром отчета
//
// Параметры
//	Нет
//
Функция ПолучитьОсновнуюФорму() Экспорт
	
	ОснФорма = ПолучитьФорму();
	ОснФорма.ОбщийОтчет = ОбщийОтчет;
	ОснФорма.ЭтотОтчет  = ЭтотОбъект;
	
	Возврат ОснФорма;
	
КонецФункции // ПолучитьОсновнуюФорму()

// Возвращает форму настройки 
//
// Параметры:
//	Нет.
//
// Возвращаемое значение:
//	
//
Функция ПолучитьФормуНастройки() Экспорт
	
	ФормаНастройки = ОбщийОтчет.ПолучитьФорму("ФормаНастройка");
	Возврат ФормаНастройки;
	
КонецФункции // ПолучитьФормуНастройки()

// Процедура обработки расшифровки
//
// Параметры:
//	Нет.
//
Процедура ОбработкаРасшифровки(РасшифровкаСтроки, ПолеТД, ВысотаЗаголовка, СтандартнаяОбработка) Экспорт
	
	// Добавление расшифровки из колонки
	Если ТипЗнч(РасшифровкаСтроки) = Тип("Структура") Тогда
		
		// Расшифровка колонки находится в заголовке колонки
		//РасшифровкаКолонки = ПолеТД.Область(ВысотаЗаголовка+2, ПолеТД.ТекущаяОбласть.Лево).Расшифровка;

		//Расшифровка = Новый Структура;

		//Для каждого Элемент Из РасшифровкаСтроки Цикл
		//	Расшифровка.Вставить(Элемент.Ключ, Элемент.Значение);
		//КонецЦикла;

		//Если ТипЗнч(РасшифровкаКолонки) = Тип("Структура") Тогда

		//	Для каждого Элемент Из РасшифровкаКолонки Цикл
		//		Расшифровка.Вставить(Элемент.Ключ, Элемент.Значение);
		//	КонецЦикла;

		//КонецЕсли; 

		//ОбщийОтчет.ОбработкаРасшифровкиСтандартногоОтчета(Расшифровка, СтандартнаяОбработка, ЭтотОбъект);

	КонецЕсли;
	
КонецПроцедуры // ОбработкаРасшифровки()

// Добавляет в структуру общие для всех отчетов параметры настройки
//
// Параметры:
//	Нет.
//
Функция СформироватьСтруктуруДляСохраненияНастроек(ПоказыватьЗаголовок) Экспорт
	
	СтруктураНастроек = Новый Структура;
	
	СтруктураНастроек.Вставить("НастройкиПостроителя", ОбщийОтчет.ПостроительОтчета.ПолучитьНастройки());
	СтруктураНастроек.Вставить("Показатели", ОбщийОтчет.Показатели.Выгрузить());
	СтруктураНастроек.Вставить("ВыводитьДополнительныеПоляВОтдельнойКолонке", ОбщийОтчет.ВыводитьДополнительныеПоляВОтдельнойКолонке);
	СтруктураНастроек.Вставить("ВыводитьИтогиПоВсемУровням", ОбщийОтчет.ВыводитьИтогиПоВсемУровням);
	СтруктураНастроек.Вставить("ВыводитьПоказателиВСтроку", ОбщийОтчет.ВыводитьПоказателиВСтроку);
	СтруктураНастроек.Вставить("РаскрашиватьИзмерения", ОбщийОтчет.РаскрашиватьИзмерения);
	СтруктураНастроек.Вставить("ЗаголовокПомечен", ОбщийОтчет.ПоказыватьЗаголовок);
	
	Возврат СтруктураНастроек;
	
КонецФункции // СформироватьСтруктуруДляСохраненияНастроек()()

// Заполняет из структуры настроек общие параметры отчетов
//
// Параметры:
//	Нет.
//
Процедура ВосстановитьНастройкиИзСтруктуры(СтруктураСНастройками, ПоказыватьЗаголовок) Экспорт
	Перем ТабПоказатели;
	
	Если ТипЗнч(ОбщийОтчет.СохраненныеНастройки) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	ОбщийОтчет.ПостроительОтчета.УстановитьНастройки(СтруктураСНастройками.НастройкиПостроителя);
	
	СтруктураСНастройками.Свойство("Показатели", ТабПоказатели);
	Если ТипЗнч(ТабПоказатели) = Тип("ТаблицаЗначений") Тогда
		ОбщийОтчет.Показатели.Загрузить(ТабПоказатели);
	КонецЕсли;
	
	СтруктураСНастройками.Свойство("ВыводитьДополнительныеПоляВОтдельнойКолонке", ОбщийОтчет.ВыводитьДополнительныеПоляВОтдельнойКолонке);
	СтруктураСНастройками.Свойство("ВыводитьИтогиПоВсемУровням", ОбщийОтчет.ВыводитьИтогиПоВсемУровням);
	СтруктураСНастройками.Свойство("ВыводитьПоказателиВСтроку", ОбщийОтчет.ВыводитьПоказателиВСтроку);
	СтруктураСНастройками.Свойство("РаскрашиватьИзмерения", ОбщийОтчет.РаскрашиватьИзмерения);
	СтруктураСНастройками.Свойство("ЗаголовокПомечен", ОбщийОтчет.ПоказыватьЗаголовок);
	
КонецПроцедуры // ВосстановитьНастройкиИзСтруктуры(СохраненныеНастройки)()

ОбщийОтчет.ИмяРегистра          = "";
ОбщийОтчет.мНазваниеОтчета      = "Отчет Balances on date";
ОбщийОтчет.мВыбиратьИмяРегистра = Ложь;
ОбщийОтчет.мРежимВводаПериода   = 1;

#КонецЕсли