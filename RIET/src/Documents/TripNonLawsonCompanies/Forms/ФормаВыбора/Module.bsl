
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("СтруктураНастройки") и Параметры.СтруктураНастройки.Имя = "ВыборИзRentalTracking" Тогда		
		
		Этаформа.Элементы.Список.РежимВыбора = Истина;
		
		//Если Параметры.СтруктураНастройки.Имя = "ВыборИзAPInvoice" Тогда
		//	
		//	СтруктураНастройки = Параметры.СтруктураНастройки;
		//	ТаблицаTrips = Документы.APInvoice.НастроитьДляВыбораИзAPInvoice(СтруктураНастройки.ServiceProvider, СтруктураНастройки.LegalEntity);
		//	МассивTrips = ТаблицаTrips.ВыгрузитьКолонку("Trip");
		//	СписокTrips = Новый СписокЗначений; 
		//	СписокTrips.ЗагрузитьЗначения(МассивTrips);
		//	
		//	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		//	Список,
		//	"Trip",
		//	СписокTrips,
		//	ВидСравненияКомпоновкиДанных.ВСписке,
		//	,
		//	Истина,
		//	РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
		//	
		//ИначеЕсли Параметры.СтруктураНастройки.Имя = "ВыборИзRentalTracking" Тогда
			
			СтруктураНастройки = Параметры.СтруктураНастройки;
			ТаблицаTrips = Документы.RentalTrucksCostsSums.НастроитьДляВыбораИзRentalTracking(СтруктураНастройки.ServiceProvider, СтруктураНастройки.ДатаНачала, СтруктураНастройки.ДатаОкончания);
			МассивTrips = ТаблицаTrips.ВыгрузитьКолонку("Trip");
			СписокTrips = Новый СписокЗначений; 
			СписокTrips.ЗагрузитьЗначения(МассивTrips);
			
			ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
			Список,
			"Trip",
			СписокTrips,
			ВидСравненияКомпоновкиДанных.ВСписке,
			,
			Истина,
			РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
			
		//КонецЕсли;
		
	Иначе 
		
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		Список,
		"Specialist",
		ПараметрыСеанса.ТекущийПользователь,
		ВидСравненияКомпоновкиДанных.Равно,
		,
		Ложь,
		РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
		
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		Список,
		"Stage",
		,
		ВидСравненияКомпоновкиДанных.Равно,
		,
		Ложь,
		РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
		
		ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(
		Список,
		"Trip.ПометкаУдаления",
		Ложь,
		ВидСравненияКомпоновкиДанных.Равно,
		,
		Истина,
		РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Обычный);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура OpenFSTracking(Команда)
	
	ТекДанные = Элементы.Список.ТекущиеДанные;
	
	Если ЗначениеЗаполнено(ТекДанные.FSTracking) Тогда 
		ПоказатьЗначение(,ТекДанные.FSTracking);
	КонецЕсли;
	
КонецПроцедуры
