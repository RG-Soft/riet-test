
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("СтруктураНастройки") Тогда
		
		СтруктураНастройки = Параметры.СтруктураНастройки;
		Если СтруктураНастройки.Имя = "ВыборИзDOC" Тогда
			НастроитьДляВыбораИзDOC(СтруктураНастройки);
		КонецЕсли;
		
	КонецЕсли;
	
	Отбор = Параметры.Отбор;
	
	Отбор.Вставить("Отменен", Ложь);
	
	ImportExportСервер.ДобавитьОтборПоProcessLevelПриНеобходимости(Отбор, "ProcessLevel");
	
	// { RGS AFokin 13.09.2018 23:59:59 - S-I-0005710
	Если Параметры.Свойство("СписокДляОтбора") Тогда
		НастроитьСписокСОтбором(Параметры.СписокДляОтбора);
	КонецЕсли;	
	// } RGS AFokin 13.09.2018 23:59:59 - S-I-0005710
	
КонецПроцедуры

&НаСервере
Процедура НастроитьДляВыбораИзDOC(СтруктураНастройки)
	
	СтруктураОтбора = Параметры.Отбор;
	
	СтруктураОтбора.Вставить("Specialist", ПараметрыСеанса.ТекущийПользователь);
		
	Запрос = Новый Запрос;	
	Запрос.УстановитьПараметр("CurrentDOC", СтруктураНастройки.CurrentDOC);
	Запрос.УстановитьПараметр("CurrentInvoices", СтруктураНастройки.CurrentInvoices);	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	Invoice.Ссылка КАК Invoice
		|ИЗ
		|	Документ.Инвойс КАК Invoice
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК ИспользованныеInvoices
		|		ПО Invoice.Ссылка = ИспользованныеInvoices.Инвойс
		|			И ((НЕ ИспользованныеInvoices.Ссылка.Отменен))
		|			И ((НЕ ИспользованныеInvoices.Ссылка = &CurrentDOC))
		|ГДЕ
		|	(НЕ Invoice.Отменен)
		|	И ИспользованныеInvoices.Инвойс ЕСТЬ NULL 
		|	И (НЕ Invoice.Ссылка В (&CurrentInvoices))";	
		
	ПодходящиеInvoices = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Invoice");
	СписокПодходящихInvoices = Новый СписокЗначений;
	СписокПодходящихInvoices.ЗагрузитьЗначения(ПодходящиеInvoices);
	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(
		Список.Отбор,
		"Ссылка",
		ВидСравненияКомпоновкиДанных.ВСписке,
		СписокПодходящихInvoices,
		"Not in DOCs",
		Истина);
	             		
КонецПроцедуры

// { RGS AFokin 13.09.2018 23:59:59 - S-I-0005710
&НаСервере
Процедура НастроитьСписокСОтбором(МассивНомеров)
	
	Запрос = Новый Запрос;	
	Запрос.УстановитьПараметр("МассивНомеров", МассивНомеров);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Invoice.Ссылка КАК Invoice
	|ИЗ
	|	Документ.Инвойс КАК Invoice
	|ГДЕ
	|	Invoice.Номер В (&МассивНомеров)";	
	
	ПодходящиеInvoices = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Invoice");
	СписокПодходящихInvoices = Новый СписокЗначений;
	СписокПодходящихInvoices.ЗагрузитьЗначения(ПодходящиеInvoices);
	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(Список.Отбор,"Ссылка",ВидСравненияКомпоновкиДанных.ВСписке,СписокПодходящихInvoices,,Истина);
	             		
КонецПроцедуры
// } RGS AFokin 13.09.2018 23:59:59 - S-I-0005710
