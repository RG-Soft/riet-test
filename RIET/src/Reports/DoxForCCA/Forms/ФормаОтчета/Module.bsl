
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	СформироватьТабличныйДокумент();
	
КонецПроцедуры

&НаКлиенте
Процедура Refresh(Команда)
	
	СформироватьТабличныйДокумент();
	
КонецПроцедуры

&НаСервере
Процедура СформироватьТабличныйДокумент()
	
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
	
	Запрос = Новый Запрос;
	ТекущаяДатаНаСахалине = ТекущаяДата() + 7*60*60;
	Запрос.УстановитьПараметр("ТекущаяДатаНаСахалине", ТекущаяДатаНаСахалине);
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПоставкаУпаковочныеЛисты.Ссылка КАК Shipment,
		|	ПоставкаУпаковочныеЛисты.Ссылка.WBList КАК WBList,
		|	ПоставкаУпаковочныеЛисты.Ссылка.DOCList КАК DOCList,
		|	ПоставкаУпаковочныеЛисты.Ссылка.ETA КАК ETA,
		|	ПоставкаУпаковочныеЛисты.Ссылка.CurrentComment КАК ShipmentComment,
		|	КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Инвойс.Номер КАК InvoiceNo,
		|	КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Инвойс.Comment КАК InvoiceComment,
		|	РАЗНОСТЬДАТ(&ТекущаяДатаНаСахалине, ПоставкаУпаковочныеЛисты.Ссылка.ETA, ДЕНЬ) - 5 КАК Aging
		|ИЗ
		|	Документ.Поставка.УпаковочныеЛисты КАК ПоставкаУпаковочныеЛисты
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы
		|		ПО ПоставкаУпаковочныеЛисты.УпаковочныйЛист = КонсолидированныйПакетЗаявокНаПеревозкуИнвойсы.Ссылка
		|ГДЕ
		|	НЕ ПоставкаУпаковочныеЛисты.Ссылка.Отменен
		|	И ПоставкаУпаковочныеЛисты.Ссылка.ProcessLevel = ЗНАЧЕНИЕ(Справочник.ProcessLevels.RUEA)
		|	И ПоставкаУпаковочныеЛисты.Ссылка.ETA <> ДАТАВРЕМЯ(1, 1, 1)
		|	И ПоставкаУпаковочныеЛисты.Ссылка.DoxForCCA = ДАТАВРЕМЯ(1, 1, 1)
		|
		|УПОРЯДОЧИТЬ ПО
		|	ETA";
				
	Таблица = Запрос.Выполнить().Выгрузить();
	ЗафиксироватьТранзакцию();
		
	// Распечатаем данные
	ОтчетОбъект = РеквизитФормыВЗначение("Отчет");
	Макет = ОтчетОбъект.ПолучитьМакет("Макет");
	ТабличныйДокумент.Очистить();
	
	// Шапка	
	ОбластьШапка = Макет.ПолучитьОбласть("Шапка");	
	ТабличныйДокумент.Вывести(ОбластьШапка);

	// Шапка таблицы
	ОбластьШапкаТаблицы = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ТабличныйДокумент.Вывести(ОбластьШапкаТаблицы);
		
	// Таблица
	СтруктураПоиска = Новый Структура("Shipment"); 
	Пока Таблица.Количество() Цикл
		
		СтрокаТаблицы = Таблица[0];
		СтруктураПоиска.Shipment = СтрокаТаблицы.Shipment;
		НайденныеСтроки = Таблица.НайтиСтроки(СтруктураПоиска);
		
		Invoices = "";
		InvoicesComments = "";
		Для Каждого НайденнаяСтрока Из НайденныеСтроки Цикл
			
			Invoices = Invoices + ", " + СокрЛП(НайденнаяСтрока.InvoiceNo);
			InvoicesComments = InvoicesComments + "
				|" + НайденнаяСтрока.InvoiceComment;
			
		КонецЦикла;
		Invoices = Сред(Invoices, 3);
		InvoicesComments = Сред(InvoicesComments, 2);	
		
		ОбластьДеталиДокумента = Макет.ПолучитьОбласть("СтрокаТаблицы");
		ПараметрыОбласти = ОбластьДеталиДокумента.Параметры;
		
		ПараметрыОбласти.Shipment = СтрокаТаблицы.Shipment;
		ПараметрыОбласти.WayBills = СтрокаТаблицы.WBList;
		ПараметрыОбласти.Invoices = Invoices;
		ПараметрыОбласти.PackingLists = СтрокаТаблицы.DOCList;
		ПараметрыОбласти.ETA = СтрокаТаблицы.ETA;
		ПараметрыОбласти.Aging = СтрокаТаблицы.Aging;
		ПараметрыОбласти.ShipmentComment = СтрокаТаблицы.ShipmentComment;
		ПараметрыОбласти.InvoicesComments = InvoicesComments;
		
	 	ТабличныйДокумент.Вывести(ОбластьДеталиДокумента);
		
		Для Каждого НайденнаяСтрока Из НайденныеСтроки Цикл
			Таблица.Удалить(НайденнаяСтрока);
		КонецЦикла;
		
	КонецЦикла;
	
	// Подвал
	ОбластьПодвал = Макет.ПолучитьОбласть("Подвал");
	ОбластьПодвал.Параметры.ТекущаяДата = ТекущаяДатаНаСахалине;
	ТабличныйДокумент.Вывести(ОбластьПодвал);
			
КонецПроцедуры

&НаКлиенте
Процедура ТабличныйДокументВыбор(Элемент, Область, СтандартнаяОбработка)
	
	Если Область.СодержитЗначение И ТипЗнч(Область.Значение) = Тип("ДокументСсылка.Поставка") Тогда
		ПоказатьЗначение(,Область.Значение);
	КонецЕсли;
	
КонецПроцедуры

