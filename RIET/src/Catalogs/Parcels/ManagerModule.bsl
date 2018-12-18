
Функция ЗаполнитьInvoiceLineВParcelLine(ParcelLine, DONo, LocalOnly, ExportRequest, TransportRequest, CurrentParcel, ParcelGoods) Экспорт
	
	СоответствиеInvoiceLinesИQty = ImportExportКлиентСервер.ПолучитьСоответствиеInvoiceLineИParcelQty(ParcelGoods, ParcelLine.НомерСтроки);
	
	ТаблицаInvoiceLines = ПолучитьТаблицуInvoiceLinesПодходящихДляParcelLine(DONo, LocalOnly, ExportRequest, TransportRequest, CurrentParcel, СоответствиеInvoiceLinesИQty, ParcelLine);
	
	КоличествоНайденныхInvoiceLines = ТаблицаInvoiceLines.Количество();
	Если КоличествоНайденныхInvoiceLines = 1 Тогда
		
		ParcelLine.СтрокаИнвойса = ТаблицаInvoiceLines[0].InvoiceLine;
		ImportExportКлиентСервер.ПерезаполнитьParcelLineПоInvoiceLineПриНеобходимости(ЗначениеЗаполнено(ExportRequest), ParcelLine, ТаблицаInvoiceLines[0]);
			
	КонецЕсли;	
	
	Возврат КоличествоНайденныхInvoiceLines;
	
КонецФункции

Функция ПолучитьТаблицуInvoiceLinesПодходящихДляParcelLine(DONo, LocalOnly, ExportRequest, TransportRequest, 
		CurrentParcel, СоответствиеInvoiceLinesИQty, ParcelLine) Экспорт
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("CurrentParcel", CurrentParcel);
		
	Запрос.Текст =
		"ВЫБРАТЬ
		|	InvoiceLine.Ссылка КАК InvoiceLine,
		|	InvoiceLine.НомерЗаявкиНаЗакупку КАК PONo,
		|	InvoiceLine.СтрокаЗаявкиНаЗакупку.НомерСтрокиЗаявкиНаЗакупку КАК POLineNo,
		|	InvoiceLine.Количество КАК Qty,
		|	InvoiceLine.ЕдиницаИзмерения КАК UOM,
		|	InvoiceLine.ImportReference КАК Reference,
		|	InvoiceLine.СерийныйНомер КАК SerialNo,
		|	InvoiceLine.NetWeight,
		|	СУММА(ЕСТЬNULL(ParcelsItems.Qty, 0)) КАК ParcelsQty
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК InvoiceLine
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Parcels.Детали КАК ParcelsItems
		|		ПО InvoiceLine.Ссылка = ParcelsItems.СтрокаИнвойса
		|			И ((НЕ ParcelsItems.Ссылка.Отменен))
		|			И (ParcelsItems.Ссылка <> &CurrentParcel)
		|ГДЕ
		|	(НЕ InvoiceLine.ПометкаУдаления)";
		
	Если LocalOnly Тогда
		
		Если ЗначениеЗаполнено(TransportRequest) Тогда
			
			Запрос.УстановитьПараметр("TransportRequest", TransportRequest);
			Запрос.Текст = Запрос.Текст + "
			|	И InvoiceLine.TransportRequest = &TransportRequest";
			
			МинимальноеQty = 1;
			
		иначе
			
			// В локальных парселях инвойс и export request должен быть пустым, 
			// а количество в определенных случаях может быть нулевым
			Запрос.Текст = Запрос.Текст + "
			|	И InvoiceLine.Инвойс = ЗНАЧЕНИЕ(Документ.Инвойс.ПустаяСсылка)
			|	И InvoiceLine.ExportRequest = ЗНАЧЕНИЕ(Документ.ExportRequest.ПустаяСсылка)
			|	И (Invoiceline.Количество > 0 ИЛИ InvoiceLine.Количество = 0 И ParcelsItems.Qty ЕСТЬ NULL)";
			
			МинимальноеQty = 0;
			
		КонецЕсли;
		
	ИначеЕсли ЗначениеЗаполнено(ExportRequest) Тогда
		
		Запрос.УстановитьПараметр("ExportRequest", ExportRequest);
		Запрос.Текст = Запрос.Текст + "
			|	И InvoiceLine.ExportRequest = &ExportRequest";
			
		МинимальноеQty = 1;
		
	Иначе		
		
		// В импортных парселях инвойс не должен быть отменен
		Запрос.Текст = Запрос.Текст + "
			|	И InvoiceLine.Инвойс.Отменен = ЛОЖЬ";
			
		Запрос.УстановитьПараметр("DONo", DONo);
		Запрос.Текст = Запрос.Текст + "
			|	И InvoiceLine.Инвойс.НомерЗаявкиНаДоставку = &DONo";
			
		МинимальноеQty = 1;
			
	КонецЕсли; 	
	
	Если ParcelLine <> Неопределено Тогда
		
		Если НЕ ЗначениеЗаполнено(ExportRequest) И НЕ ЗначениеЗаполнено(TransportRequest) Тогда
			
			PONo = СокрЛП(ParcelLine.НомерЗаявкиНаЗакупку);
			Если ЗначениеЗаполнено(PONo) Тогда
				
				Запрос.УстановитьПараметр("PONo", PONo);
				Запрос.Текст = Запрос.Текст + "
					|	И InvoiceLine.НомерЗаявкиНаЗакупку = &PONo";
					
			КонецЕсли; 
			
			Если ЗначениеЗаполнено(ParcelLine.СтрокаЗаявкиНаЗакупку) Тогда
				
				Запрос.УстановитьПараметр("POLineNo", ParcelLine.СтрокаЗаявкиНаЗакупку);
				Запрос.Текст = Запрос.Текст + "
					|	И InvoiceLine.СтрокаЗаявкиНаЗакупку.НомерСтрокиЗаявкиНаЗакупку = &POLineNo";
					
			КонецЕсли; 
			
			Receiver = СокрЛП(ParcelLine.Receiver);
			Если ЗначениеЗаполнено(Receiver) Тогда
				
				Запрос.УстановитьПараметр("Receiver", Receiver);
				Запрос.Текст = Запрос.Текст + "
					|	И InvoiceLine.ImportReference = &Receiver";
				
			КонецЕсли; 
			
		КонецЕсли;
			
		SerialNo = СокрЛП(ParcelLine.СерийныйНомер);
		Если ЗначениеЗаполнено(SerialNo) Тогда
			
			Запрос.УстановитьПараметр("SerialNo", SerialNo);
			Запрос.Текст = Запрос.Текст + "
				|	И InvoiceLine.СерийныйНомер = &SerialNo";
				
		КонецЕсли; 
		
		Если ЗначениеЗаполнено(ParcelLine.Qty) Тогда
			
			Запрос.УстановитьПараметр("Qty", ParcelLine.Qty);	
			Запрос.Текст = Запрос.Текст + "
				|	И InvoiceLine.Количество >= &Qty";
				
			МинимальноеQty = ParcelLine.Qty;
			
		КонецЕсли; 
			
		Если ЗначениеЗаполнено(ParcelLine.QtyUOM) Тогда
			
			Запрос.УстановитьПараметр("QtyUOM", ParcelLine.QtyUOM);
			Запрос.Текст = Запрос.Текст + "
				|	И InvoiceLine.ЕдиницаИзмерения = &QtyUOM";
				
		КонецЕсли; 
			
	КонецЕсли;
	
	Запрос.Текст = Запрос.Текст + "
		|
		|СГРУППИРОВАТЬ ПО
		|	InvoiceLine.Ссылка,
		|	InvoiceLine.НомерЗаявкиНаЗакупку,
		|	InvoiceLine.СтрокаЗаявкиНаЗакупку.НомерСтрокиЗаявкиНаЗакупку,
		|	InvoiceLine.Количество,
		|	InvoiceLine.ЕдиницаИзмерения,
		|	InvoiceLine.ImportReference,
		|	InvoiceLine.NetWeight,
		|	InvoiceLine.СерийныйНомер
		|
		|ИМЕЮЩИЕ InvoiceLine.Количество = 0 ИЛИ InvoiceLine.Количество > СУММА(ЕСТЬNULL(ParcelsItems.Qty, 0))";
		
	Таблица = Запрос.Выполнить().Выгрузить();
	
	// Отфильтруем таблицу по свободному количеству
	ы = 0;
	Пока ы < Таблица.Количество() Цикл
		
		СтрокаТаблицы = Таблица[ы];
		
		QtyInCurrentParcel = СоответствиеInvoiceLinesИQty.Получить(СтрокаТаблицы.InvoiceLine);
		Если QtyInCurrentParcel <> Неопределено Тогда
			СтрокаТаблицы.ParcelsQty = СтрокаТаблицы.ParcelsQty + QtyInCurrentParcel;
		КонецЕсли; 
		
		Если (СтрокаТаблицы.Qty - СтрокаТаблицы.ParcelsQty) < МинимальноеQty Тогда
			Таблица.Удалить(СтрокаТаблицы);
		Иначе
			ы = ы + 1;
		КонецЕсли; 
		
	КонецЦикла; 
	
	Возврат Таблица;
	
КонецФункции

Процедура ОбработкаПолученияФормы(ВидФормы, Параметры, ВыбраннаяФорма, ДополнительнаяИнформация, СтандартнаяОбработка)
	
	Если (Параметры.Свойство("ЗначенияЗаполнения") И Параметры.ЗначенияЗаполнения.Свойство("TransportRequest")) 
		ИЛИ (Параметры.Свойство("ЗначениеКопирования") И ЗначениеЗаполнено(Параметры.ЗначениеКопирования.TransportRequest))
		ИЛИ (Параметры.Свойство("Ключ") И ЗначениеЗаполнено(
			ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Параметры.Ключ, "TransportRequest"))) Тогда 
		
		СтандартнаяОбработка = Ложь;
		ВыбраннаяФорма = "ФормаЭлементаДляTransportRequest";
		
	КонецЕсли;
	
КонецПроцедуры
