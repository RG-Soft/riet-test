
// СтандартныеПодсистемы

// Хранилище глобальных переменных.
//
// ПараметрыПриложения - Соответствие - хранилище переменных, где:
//   * Ключ - Строка - имя переменной в формате "ИмяБиблиотеки.ИмяПеременной";
//   * Значение - Произвольный - значение переменной.
//
// Инициализация (на примере СообщенияДляЖурналаРегистрации):
//   ИмяПараметра = "СтандартныеПодсистемы.СообщенияДляЖурналаРегистрации";
//   Если ПараметрыПриложения[ИмяПараметра] = Неопределено Тогда
//     ПараметрыПриложения.Вставить(ИмяПараметра, Новый СписокЗначений);
//   КонецЕсли;
//  
// Использование (на примере СообщенияДляЖурналаРегистрации):
//   ПараметрыПриложения["СтандартныеПодсистемы.СообщенияДляЖурналаРегистрации"].Добавить(...);
//   ПараметрыПриложения["СтандартныеПодсистемы.СообщенияДляЖурналаРегистрации"] = ...;
Перем ПараметрыПриложения Экспорт;

// Конец СтандартныеПодсистемы

// { RG-SOFT начало добавления

Перем глОбщиеЗначения Экспорт;

// Переменная для хранения текущего пользователя ("Справочник.Пользователи")
Перем глТекущийПользователь Экспорт;

// Учет ведется по одной организации - или по нескольким.
Перем УчетПоВсемОрганизациям Экспорт;
Перем ОсновнаяОрганизация Экспорт;

Перем УчетПоВсемОтветственным Экспорт;
Перем ОсновнойОтветственный Экспорт;
Перем УчетПоВсемИнвойсинговымЦентрам Экспорт;
Перем ОсновнойИнвойсинговыйЦентр Экспорт;

// Быстрый доступ к бухгалтерским итогам 
Перем БИ Экспорт;

Перем ПараметрыВнешнихРегламентированныхОтчетов Экспорт;

Перем КонтекстЭДО Экспорт;

// } RG-SOFT конец добавления


#Область ОбработчикиСобытий

Процедура ПередНачаломРаботыСистемы()
	
	// СтандартныеПодсистемы
	СтандартныеПодсистемыКлиент.ПередНачаломРаботыСистемы();
	// Конец СтандартныеПодсистемы
	
КонецПроцедуры

Процедура ПриНачалеРаботыСистемы()
	
	//Добавила Федотова Л., РГ-Софт, 02.02.15, вопрос SLI-0005153
	глТекущийПользователь = ПараметрыСеанса.ТекущийПользователь;
	
	//Добавила Федотова Л., РГ-Софт, 09.02.15, вопрос SLI-0005177
	КонтекстЭДО = ДокументооборотСКОВызовСервера.ПолучитьОбработкуЭДО();

	ПараметрыВнешнихРегламентированныхОтчетов = ПараметрыСеанса.ПараметрыВнешнихРегламентированныхОтчетов;
	
	// СтандартныеПодсистемы
	СтандартныеПодсистемыКлиент.ПриНачалеРаботыСистемы();
	// Конец СтандартныеПодсистемы
	
	// { RG-SOFT начало добавления
	БИ = Обработки.БухгалтерскиеИтоги.Создать();
	
	// отработка режима завершения работы системы
	
	Если ЗавершениеРаботыПользователей.ОбработатьПараметрЗапуска() Тогда
		Возврат;
	КонецЕсли;
	
	ЗавершениеРаботыПользователей.УстановитьКонтрольРежимаЗавершенияРаботыПользователей();

	ОсновнаяОрганизация  = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глТекущийПользователь, "ОсновнаяОрганизация");

	УчетПоВсемОрганизациям = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глТекущийПользователь, "УчетПоВсемОрганизациям");
	
	//РГ-Софт, Прокошева	
	УчетПоВсемОтветственным = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глТекущийПользователь, "УчетПоВсемОтветственным");
    ОсновнойОтветственный    = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глТекущийПользователь, "ОсновнойОтветственный");
	
	УчетПоВсемИнвойсинговымЦентрам = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глТекущийПользователь, "УчетПоВсемИнвойсинговымЦентрам");
    ОсновнойИнвойсинговыйЦентр    = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глТекущийПользователь, "ОсновнойИнвойсинговыйЦентр");
	
	#Если Клиент Тогда
	Обработки.ОтчетПоОбновлениям.ПолучитьФорму().Открыть();
	
	НастройкаПравДоступа.ПроверитьЗадачи(глТекущийПользователь);	
	#КонецЕсли
	// } RG-SOFT конец добавления
	
	// { RGS LFedotova 12.03.2017 21:54:49 - вопрос SLI-0007202
	Если РГСофтСерверПовтИспСеанс.ЭтоLogelco() Тогда
		ПодключитьОбработчикОжидания("ВыполнитьЗагрузкуAU", 60*60);
	КонецЕсли;
	// } RGS LFedotova 12.03.2017 21:55:18 - вопрос SLI-0007202
	
КонецПроцедуры

Процедура ПередЗавершениемРаботыСистемы(Отказ)
	
	// СтандартныеПодсистемы
	СтандартныеПодсистемыКлиент.ПередЗавершениемРаботыСистемы(Отказ);
	// Конец СтандартныеПодсистемы
	
КонецПроцедуры

Процедура ОткрытьСправкуПоКонфигурации() Экспорт
	
	ОткрытьСправку("Конфигурация");
	
КонецПроцедуры

// Открывает форму текущего пользователя для изменения его настроек.
//
// Параметры:
//  Нет.
//
Процедура ОткрытьФормуТекущегоПользователя() Экспорт

	Если ОбщегоНазначения.ЗначениеНеЗаполнено(глТекущийПользователь) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не задан текущий пользователь.");

	Иначе
		глТекущийПользователь.ПолучитьФорму().Открыть();

	КонецЕсли;

КонецПроцедуры // ОткрытьФормуТекущегоПользователя()


///////////////////////////////////////////////////////////////////////////////
// УДАЛИТЬ

// Функция возвращает значение экспортных переменных модуля приложений
//
// Параметры
//  ИмяПеременной - строка, содержит имя переменной целиком 
//
// Возвращаемое значение:
//   значение соответствующей экспортной переменной
//
Функция глЗначениеПеременной(ИмяПеременной) Экспорт
	
	Возврат ОбщегоНазначения.ПолучитьЗначениеПеременной(ИмяПеременной, глОбщиеЗначения);
	
КонецФункции

#КонецОбласти

глОбработкаАвтоОбменДанными = Неопределено;

глКоличествоСекундОпросаОбмена = ПроцедурыОбменаДанными.ПолучитьКоличествоСекундОпросаЗапускаОбменаДанными();
