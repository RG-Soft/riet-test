&НаКлиенте
Перем ПараметрыОбработчикаОжидания;

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// СтандартныеПодсистемы.Печать
	//УправлениеПечатью.ПриСозданииНаСервере(ЭтаФорма, Элементы.ГруппаПечать);
	// Конец СтандартныеПодсистемы.Печать
	
	// ДополнительныеОтчетыИОбработки
	//ДополнительныеОтчетыИОбработки.ПриСозданииНаСервере(ЭтаФорма, ДополнительныеОтчетыИОбработкиКлиентСервер.ТипФормыОбъекта());
	// Конец ДополнительныеОтчетыИОбработки
	
	Если Параметры.Ключ.Пустая() Тогда
		ПодготовитьФормуНаСервере();
	КонецЕсли;
	
	ЗапуститьПроверкуКонтрагентовПриСозданииНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	// СтандартныеПодсистемы.ДатыЗапретаИзменения
	//ДатыЗапретаИзменения.ОбъектПриЧтенииНаСервере(ЭтаФорма, ТекущийОбъект);
	// Конец СтандартныеПодсистемы.ДатыЗапретаИзменения
	
	ПодготовитьФормуНаСервере();
	
	ПроверкаКонтрагентов.ПриЧтенииНаСервере(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	Если ПараметрыЗаписи.РежимЗаписи = ПредопределенноеЗначение("РежимЗаписиДокумента.Проведение") Тогда
		КлючеваяОперация = "ПроведениеСчетФактураПолученныйБланкСтрогойОтчетности";
		//ОценкаПроизводительностиКлиентСервер.НачатьЗамерВремени(КлючеваяОперация);
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	Если ИспользованиеПроверкиВозможно Тогда
		ПроверкаКонтрагентов.СохранитьРезультатПроверкиКонтрагентовПослеЗаписи(ЭтотОбъект);
	КонецЕсли;
	
	ПредставлениеДокумента = Документы.СчетФактураПолученный.ПолучитьПредставлениеДокумента(Объект.Ссылка, Объект.ВидСчетаФактуры);
	УстановитьЗаголовокФормы(ЭтаФорма, ПредставлениеДокумента);
	УстановитьСостояниеДокумента();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	ОбщегоНазначенияБПКлиент.ОбработкаОповещенияФормыДокумента(ЭтаФорма, Объект.Ссылка, ИмяСобытия, Параметр, Источник);
	
	ПроверитьКонтрагентовПриНаступленииСобытия(ИмяСобытия, Параметр, Источник);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	ПроверкаКонтрагентовКлиент.СохранитьРезультатПроверкиКонтрагентовПриЗакрытии(ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПроверитьКонтрагентовПриОткрытии();

КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	Оповестить("Запись_СчетФактураПолученный", ПараметрыЗаписи, Объект.Ссылка);
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ БСП

// СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки

&НаСервере
Процедура ДополнительныеОтчетыИОбработкиВыполнитьНазначаемуюКомандуНаСервере(ИмяЭлемента, РезультатВыполнения)
	
	//ДополнительныеОтчетыИОбработки.ВыполнитьНазначаемуюКомандуНаСервере(ЭтаФорма, ИмяЭлемента, РезультатВыполнения);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ВыполнитьНазначаемуюКоманду(Команда)
	
	//Если НЕ ДополнительныеОтчетыИОбработкиКлиент.ВыполнитьНазначаемуюКомандуНаКлиенте(ЭтаФорма, Команда.Имя) Тогда
	//	РезультатВыполнения = Неопределено;
	//	ДополнительныеОтчетыИОбработкиВыполнитьНазначаемуюКомандуНаСервере(Команда.Имя, РезультатВыполнения);
	//	ДополнительныеОтчетыИОбработкиКлиент.ПоказатьРезультатВыполненияКоманды(ЭтаФорма, РезультатВыполнения);
	//КонецЕсли;
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки

// СтандартныеПодсистемы.Печать
&НаКлиенте
Процедура Подключаемый_ВыполнитьКомандуПечати(Команда)
	
	УправлениеПечатьюКлиент.ВыполнитьПодключаемуюКомандуПечати(Команда, ЭтаФорма, Объект);
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.Печать

////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

&НаСервере
Процедура ПодготовитьФормуНаСервере()
	
	УстановитьФункциональныеОпцииФормы();
	
	УстановитьСостояниеДокумента();
	
	ПредставлениеДокумента = Документы.СчетФактураПолученный.ПолучитьПредставлениеДокумента(Объект.Ссылка, Объект.ВидСчетаФактуры);
	УстановитьЗаголовокФормы(ЭтаФорма, ПредставлениеДокумента);
	
	ДекорацияОтветственный = ВернутьСтр("ru = 'Ответственный:'");
	
	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьСостояниеДокумента()
	
	СостояниеДокумента = ОбщегоНазначенияБП.СостояниеДокумента(Объект);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьФункциональныеОпцииФормы()
	
	//ОбщегоНазначенияБПКлиентСервер.УстановитьПараметрыФункциональныхОпцийФормыДокумента(ЭтаФорма);
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеФормой(Форма)
	
	Элементы	= Форма.Элементы;
	Объект		= Форма.Объект;
	
	Элементы.НДСПредъявленКВычету.Доступность  = УчетНДСКлиентСервер.Версия(Объект.Дата) >= 2;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьЗаголовокФормы(Форма, ПредставлениеДокумента)
	
	Форма.Заголовок = ПредставлениеДокумента.СчетФактураПредставление;
	
КонецПроцедуры

#Область ПроверкаКонтрагентов

&НаКлиенте
Процедура Подключаемый_ПоказатьПредложениеИспользоватьПроверкуКонтрагентов()
	
	ПроверкаКонтрагентовКлиент.ПредложитьВключитьПроверкуКонтрагентов(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьПроверкуКонтрагентов(ДополнительныеПараметры = Неопределено)
	
	Если ИспользованиеПроверкиВозможно Тогда
		
		ПараметрыФоновогоЗадания = ПроверкаКонтрагентовКлиент.ПараметрыФоновогоЗадания(ДополнительныеПараметры);
		ПроверитьКонтрагентовФоновоеЗадание(ПараметрыФоновогоЗадания);
		ДлительныеОперацииКлиент.ИнициализироватьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
		
		// Прерываем предыдущую проверку
		ПодключитьОбработчикОжидания("Подключаемый_ОбработатьРезультатПроверкиКонтрагентов", 1, Истина);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбработатьРезультатПроверкиКонтрагентов()
	
	ФоновоеЗаданиеЗавершилось = ПроверкаКонтрагентовВызовСервера.ПроверкаКонтрагентовЗавершилась(ИдентификаторЗаданияПроверкиКонтрагента);
	
	// Если есть незавершившиеся фоновые задания, то продолжаем ждать результат
	Если ФоновоеЗаданиеЗавершилось Тогда
		ОтобразитьРезультатПроверкиКонтрагента();
	Иначе
		ДлительныеОперацииКлиент.ОбновитьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
		ПодключитьОбработчикОжидания("Подключаемый_ОбработатьРезультатПроверкиКонтрагентов", ПараметрыОбработчикаОжидания.ТекущийИнтервал, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОтобразитьРезультатПроверкиКонтрагента()
	ПроверкаКонтрагентов.ОтобразитьРезультатПроверкиКонтрагента(ЭтотОбъект);
КонецПроцедуры

&НаСервере
Процедура ПроверитьКонтрагентовФоновоеЗадание(ДополнительныеПараметры = Неопределено)
	
	ПроверкаКонтрагентов.ПроверитьКонтрагентовВДокументеФоновоеЗадание(ЭтотОбъект, ДополнительныеПараметры);
		
КонецПроцедуры

&НаСервере
Процедура ЗапуститьПроверкуКонтрагентовПриСозданииНаСервере()
	
	ИспользованиеПроверкиВозможно = ПроверкаКонтрагентовВызовСервера.ИспользованиеПроверкиВозможно();
	
	Если ИспользованиеПроверкиВозможно Тогда
		ПроверкаКонтрагентов.УправлениеФормойПриСозданииНаСервере(ЭтотОбъект);
		ПроверитьКонтрагентовФоновоеЗадание();
	Иначе
		ПроверкаКонтрагентов.ПрорисоватьСостоянияКонтрагентовВДокументе(ЭтотОбъект, Перечисления.СостоянияПроверкиКонтрагентов.ПроверкаНеИспользуется);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьКонтрагентовПриОткрытии()
	
	Если ИспользованиеПроверкиВозможно Тогда
		ДлительныеОперацииКлиент.ИнициализироватьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
		ПодключитьОбработчикОжидания("Подключаемый_ОбработатьРезультатПроверкиКонтрагентов", 0.1, Истина);
	Иначе
		ПодключитьОбработчикОжидания("Подключаемый_ПоказатьПредложениеИспользоватьПроверкуКонтрагентов", 0.1, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ТребуетсяПроверкаКонтрагентов(Источник) 
	Возврат ПроверкаКонтрагентов.ТребуетсяПроверкаКонтрагентов(ЭтотОбъект, Источник);
КонецФункции

&НаКлиенте
Процедура ПроверитьКонтрагентовПриНаступленииСобытия(ИмяСобытия, Параметр, Источник)
	
	Если ПроверкаКонтрагентовКлиент.СобытиеТребуетПроверкиКонтрагента(ЭтотОбъект, ИмяСобытия, Параметр, Источник)
		И ТребуетсяПроверкаКонтрагентов(Источник) Тогда
		
		ЗапуститьПроверкуКонтрагентов(Источник);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти