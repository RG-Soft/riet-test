
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Не Параметры.Свойство("Ticket") Тогда 
		Отказ = Истина;
		Возврат;
	КонецЕсли;

	Ticket = Параметры.Ticket;
	TicketОбъект = Ticket.ПолучитьОбъект();
	
	Если TicketОбъект.Тип = "Credit note" ИЛИ TicketОбъект.Тип = "Кредит-нота" 
		ИЛИ TicketОбъект.Тип = Перечисления.ТипыТикетов.КредитНота Тогда
		
		Элементы.ВидОперации.РежимВыбораИзСписка = Истина;
		МассивВидовОперации = Новый Массив;
		МассивВидовОперации.Добавить(Перечисления.ВидыОперацийРеализацияТоваров.КредитНотаОтрицатСФ);
		МассивВидовОперации.Добавить(Перечисления.ВидыОперацийРеализацияТоваров.КредитНотаСторно);
		Элементы.ВидОперации.СписокВыбора.ЗагрузитьЗначения(МассивВидовОперации);
		
	иначе 
		
		ВидОперации = Перечисления.ВидыОперацийРеализацияТоваров.ПродажаКомиссия;
		
	КонецЕсли;
	
	ДоговорИзTicket = TicketОбъект.ДоговорКонтрагента;
	КонтрагентИзTicket = TicketОбъект.Контрагент;
	
	ВалютаИзTicket = ?(ЗначениеЗаполнено(TicketОбъект.Валюта), TicketОбъект.Валюта, TicketОбъект.ДоговорКонтрагента.ВалютаВзаиморасчетов);
	Валюта = ВалютаИзTicket;
	Если ВалютаИзTicket = Константы.ВалютаРегламентированногоУчета.Получить() Тогда
		Элементы.Валюта.Видимость = Ложь;
		Элементы.КурсВзаиморасчетов.Видимость = Ложь;
	иначе
		МассивВалют = Новый Массив;	
		МассивВалют.Добавить(Справочники.Валюты.НайтиПоКоду("643"));
		МассивВалют.Добавить(Справочники.Валюты.НайтиПоКоду("840"));
		Элементы.Валюта.СписокВыбора.ЗагрузитьЗначения(МассивВалют);
	КонецЕсли;
       	        	
	КурсВзаиморасчетов = ДоговорИзTicket.Курс;
	КратностьВзаиморасчетов = 1;
	
	Если КурсВзаиморасчетов = 0 Тогда
		СтруктураНовогоКурсаВалюты  = ОбщегоНазначения.ПолучитьКурсВалюты(Валюта, TicketОбъект.Дата);
		КурсВзаиморасчетов      = СтруктураНовогоКурсаВалюты.Курс;
		КратностьВзаиморасчетов = СтруктураНовогоКурсаВалюты.Кратность;
	КонецЕсли;
	
	СуммаТикета = SalesBook.ПолучитьОстатокПоТикету(, Ticket);
	ПриИзмененииВидаОперации();
	
КонецПроцедуры

&НаКлиенте
Процедура ВидОперацииПриИзменении(Элемент)
	
	ПриИзмененииВидаОперации();
	
КонецПроцедуры

&НаСервере
Процедура ПриИзмененииВидаОперации()
	
	Если ВидОперации <> Перечисления.ВидыОперацийРеализацияТоваров.КредитНотаСторно Тогда
		Элементы.ТипРеализации.Доступность = Истина;
		ТипРеализации = 1;
	иначе
		Элементы.ТипРеализации.Доступность = Ложь;
		ТипРеализации = 0;
	КонецЕсли;
	
	Если ВидОперации = Перечисления.ВидыОперацийРеализацияТоваров.КредитНотаСторно Тогда 
		Элементы.Сделка.Доступность = Истина;
	иначе 
		Элементы.Сделка.Доступность = Ложь;
		Сделка = Неопределено;
	КонецЕсли;
	
	Если НЕ (ВидОперации = Перечисления.ВидыОперацийРеализацияТоваров.ВнутренняяКредитНота
		ИЛИ ВидОперации = Перечисления.ВидыОперацийРеализацияТоваров.КредитНотаСторно) Тогда
		Элементы.Валюта.Доступность = Истина;
		Элементы.КурсВзаиморасчетов.Доступность = Истина;
	иначе
		Элементы.Валюта.Доступность = Ложь;
		Элементы.КурсВзаиморасчетов.Доступность = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СделкаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	СтруктураПараметров  = Новый Структура("НастроитьДляВыбораСделкиКредитНотаСторно,Договор,Контрагент",
												, ДоговорИзTicket, КонтрагентИзTicket);

	Сделка = ОткрытьФормуМодально("Документ.РеализацияТоваровУслуг.ФормаВыбора", СтруктураПараметров, ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ОК(Команда)
	
	Если Не ЭтаФорма.ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	СтруктураНастройки = Новый Структура("ТипРеализации");
	СтруктураНастройки.Вставить("ВидОперации", ВидОперации);
	
	Если ТипРеализации = 1 Тогда 
		СтруктураНастройки.Вставить("ТипРеализации", "Товары");
	ИначеЕсли ТипРеализации = 2 Тогда
		СтруктураНастройки.Вставить("ТипРеализации", "Услуги");
	КонецЕсли;
	
	Если ВидОперации = ПредопределенноеЗначение("Перечисление.ВидыОперацийРеализацияТоваров.КредитНотаСторно")
		И Не ЗначениеЗаполнено(Сделка) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Заполните поле Сделка!"
			,,"Сделка");
		Возврат;
 	КонецЕсли;
	СтруктураНастройки.Вставить("Сделка", Сделка);
	
	СтруктураНастройки.Вставить("ВалютаДокумента", Валюта);
	СтруктураНастройки.Вставить("КурсВзаиморасчетов", КурсВзаиморасчетов);
	СтруктураНастройки.Вставить("КратностьВзаиморасчетов", КратностьВзаиморасчетов);
    СтруктураНастройки.Вставить("СуммаТикета", СуммаТикета);
	СтруктураНастройки.Вставить("Ticket", Ticket);
	
	ЭтаФорма.Закрыть(СтруктураНастройки);
	
КонецПроцедуры

