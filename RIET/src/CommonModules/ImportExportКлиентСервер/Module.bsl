
////////////////////////////////////////////////////////////////////
// ITEMS

Процедура ПерезаполнитьInvoiceLineПоPOLineПриНеобходимости(InvoiceLine, СтруктураДанныхPOLine=Неопределено) Экспорт 
	
	Если НЕ ЗначениеЗаполнено(InvoiceLine.СтрокаЗаявкиНаЗакупку) Тогда
		Возврат;
	КонецЕсли; 
	
	Если СтруктураДанныхPOLine = Неопределено Тогда
		СтруктураДанныхPOLine = ImportExportВызовСервера.ПолучитьСтруктуруДанныхPOLineДляInvoiceLine(InvoiceLine.СтрокаЗаявкиНаЗакупку);
	КонецЕсли; 
	
	Если НЕ ЗначениеЗаполнено(СокрЛП(InvoiceLine.КодПоИнвойсу)) Тогда
		
		PartNo = СокрЛП(СтруктураДанныхPOLine.PartNo);
		Если ЗначениеЗаполнено(PartNo) Тогда
			InvoiceLine.КодПоИнвойсу = PartNo;
		КонецЕсли;
		
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СокрЛП(InvoiceLine.НаименованиеТовара)) Тогда
		
		Description = СокрЛП(СтруктураДанныхPOLine.Description);
		Если ЗначениеЗаполнено(Description) Тогда
			InvoiceLine.НаименованиеТовара = Description;
		КонецЕсли;
		
	КонецЕсли; 
	
	Если ЗначениеЗаполнено(СтруктураДанныхPOLine.Catalog) Тогда
		Попытка
			InvoiceLine.Каталог = СтруктураДанныхPOLine.Catalog;
		Исключение
		КонецПопытки;
	КонецЕсли;
		
	Если НЕ ЗначениеЗаполнено(InvoiceLine.Количество)
		И ЗначениеЗаполнено(СтруктураДанныхPOLine.Qty) Тогда
		InvoiceLine.Количество = СтруктураДанныхPOLine.Qty;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(InvoiceLine.ЕдиницаИзмерения)
		И ЗначениеЗаполнено(СтруктураДанныхPOLine.UOM) Тогда
		InvoiceLine.ЕдиницаИзмерения	= СтруктураДанныхPOLine.UOM;
	КонецЕсли;
	
	Попытка
		Если НЕ ЗначениеЗаполнено(InvoiceLine.TransportRequest) 
			И НЕ ЗначениеЗаполнено(СокрЛП(InvoiceLine.СтранаПроисхождения))
			И ЗначениеЗаполнено(СокрЛП(СтруктураДанныхPOLine.SupplierCountry)) Тогда
			InvoiceLine.СтранаПроисхождения = СокрЛП(СтруктураДанныхPOLine.SupplierCountry);
		КонецЕсли;
	Исключение
		Если НЕ ЗначениеЗаполнено(СокрЛП(InvoiceLine.СтранаПроисхождения))
			И ЗначениеЗаполнено(СокрЛП(СтруктураДанныхPOLine.SupplierCountry)) Тогда
			InvoiceLine.СтранаПроисхождения = СокрЛП(СтруктураДанныхPOLine.SupplierCountry);
		КонецЕсли;
	КонецПопытки;

	Если НЕ ЗначениеЗаполнено(InvoiceLine.Цена)
		И ЗначениеЗаполнено(СтруктураДанныхPOLine.Price) Тогда
		InvoiceLine.Цена = СтруктураДанныхPOLine.Price;
	КонецЕсли;
	
	InvoiceLine.Сумма = InvoiceLine.Количество * InvoiceLine.Цена;
	
	Если ЗначениеЗаполнено(СтруктураДанныхPOLine.ERPTreatment) Тогда
		InvoiceLine.Классификатор = СтруктураДанныхPOLine.ERPTreatment;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(InvoiceLine.Классификатор) Тогда
		InvoiceLine.Классификатор = ПредопределенноеЗначение("Перечисление.ТипыЗаказа.E");
	КонецЕсли; 
	
	Если ЗначениеЗаполнено(СтруктураДанныхPOLine.AU) Тогда
		InvoiceLine.КостЦентр = СтруктураДанныхPOLine.AU;
	КонецЕсли;
	
	Activity = СокрЛП(СтруктураДанныхPOLine.Activity);
	Если ЗначениеЗаполнено(Activity) Тогда
		InvoiceLine.Активити = Activity;
	КонецЕсли;	
	
	Попытка
		Если Не InvoiceLine.EUCNotRequired Тогда 
			InvoiceLine.EUCNotRequired = СтруктураДанныхPOLine.EUCNotRequired;	
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(InvoiceLine.EUCRequested) Тогда
			InvoiceLine.EUCRequested = СтруктураДанныхPOLine.EUCRequested;	
		КонецЕсли; 
		
		Если Не ЗначениеЗаполнено(InvoiceLine.EUCReceived) Тогда
			InvoiceLine.EUCReceived = СтруктураДанныхPOLine.EUCReceived;	
		КонецЕсли;
	Исключение
	КонецПопытки;

	Если НЕ ЗначениеЗаполнено(InvoiceLine.ProjectMobilization)
		И ЗначениеЗаполнено(СтруктураДанныхPOLine.ProjectMobilization) Тогда
		InvoiceLine.ProjectMobilization = СтруктураДанныхPOLine.ProjectMobilization;
	КонецЕсли;
	
	// { RGS DKazanskiy 20.12.2018 13:24:07 - S-I-0006324
	Если ЗначениеЗаполнено(СтруктураДанныхPOLine.CountryOfOrigin) 
		И СокрЛП(ВРег(СтруктураДанныхPOLine.CountryOfOrigin)) = "US" Тогда
		InvoiceLine.EUCNotRequired = Ложь;
	КонецЕсли;
	// } RGS DKazanskiy 20.12.2018 13:24:10 - S-I-0006324
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////
// PARCELS

Процедура ПерезаполнитьParcelLineПоInvoiceLineПриНеобходимости(ЭтоЭкспортныйParcel, ParcelLine, ДанныеInvoiceLine=Неопределено) Экспорт 
	
	Если НЕ ЗначениеЗаполнено(ParcelLine.СтрокаИнвойса) Тогда
		Возврат;
	КонецЕсли; 
	
	Если ДанныеInvoiceLine = Неопределено Тогда
		ДанныеInvoiceLine = ImportExportВызовСервера.ПолучитьДанныеItemsДляParcelLines(ParcelLine.СтрокаИнвойса)[ParcelLine.СтрокаИнвойса];
	КонецЕсли; 
	
	Если НЕ ЭтоЭкспортныйParcel Тогда
		
		Если НЕ ЗначениеЗаполнено(СокрЛП(ParcelLine.НомерЗаявкиНаЗакупку)) Тогда
			
			PONo = СокрЛП(ДанныеInvoiceLine.PONo);
			Если ЗначениеЗаполнено(PONo) Тогда
				ParcelLine.НомерЗаявкиНаЗакупку = PONo;
			КонецЕсли;
			
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(ParcelLine.СтрокаЗаявкиНаЗакупку)
			И ЗначениеЗаполнено(ДанныеInvoiceLine.POLineNo) Тогда
			
			ParcelLine.СтрокаЗаявкиНаЗакупку = ДанныеInvoiceLine.POLineNo;
			
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(СокрЛП(ParcelLine.Receiver)) Тогда
			
			Receiver = СокрЛП(ДанныеInvoiceLine.Reference);
			Если ЗначениеЗаполнено(Receiver) Тогда
				ParcelLine.Receiver = Receiver;
			КонецЕсли;
			
		КонецЕсли; 
		
	КонецЕсли;
		
	Если НЕ ЗначениеЗаполнено(СокрЛП(ParcelLine.СерийныйНомер)) Тогда
		
		SerialNo = СокрЛП(ДанныеInvoiceLine.SerialNo);
		Если ЗначениеЗаполнено(SerialNo) Тогда
			ParcelLine.СерийныйНомер = SerialNo;
		КонецЕсли;
		
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ParcelLine.Qty)
		И ЗначениеЗаполнено(ДанныеInvoiceLine.Qty) Тогда
		
		ParcelLine.Qty = ДанныеInvoiceLine.Qty;
		
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ParcelLine.QtyUOM)
		И ЗначениеЗаполнено(ДанныеInvoiceLine.UOM) Тогда
		
		ParcelLine.QtyUOM = ДанныеInvoiceLine.UOM;
		
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(ParcelLine.NetWeight) Тогда
		ParcelLine.NetWeight = ДанныеInvoiceLine.NetWeight;
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьСоответствиеInvoiceLineИParcelQty(ParcelGoods, ИсключаемыйНомерСтроки=Неопределено) Экспорт
	
	СоответствиеInvoiceLinesИQty = Новый Соответствие;
	Для Каждого СтрокаТЧ Из ParcelGoods Цикл
		
		Если НЕ ЗначениеЗаполнено(СтрокаТЧ.СтрокаИнвойса)
			ИЛИ НЕ ЗначениеЗаполнено(СтрокаТЧ.Qty)
			ИЛИ СтрокаТЧ.НомерСтроки = ИсключаемыйНомерСтроки Тогда
			Продолжить;
		КонецЕсли; 
		
		Если СоответствиеInvoiceLinesИQty.Получить(СтрокаТЧ.СтрокаИнвойса) = Неопределено Тогда
			СоответствиеInvoiceLinesИQty.Вставить(СтрокаТЧ.СтрокаИнвойса, СтрокаТЧ.Qty);
		Иначе
			СоответствиеInvoiceLinesИQty[СтрокаТЧ.СтрокаИнвойса] = СоответствиеInvoiceLinesИQty[СтрокаТЧ.СтрокаИнвойса] + СтрокаТЧ.Qty;
		КонецЕсли; 
		
	КонецЦикла;
	
	Возврат СоответствиеInvoiceLinesИQty;
	
КонецФункции 

Процедура ПересчитатьРазмерыИВесParcel(Объект, CM, KG) Экспорт 
	
	// Размеры
	Если ЗначениеЗаполнено(Объект.DIMsUOM) Тогда
		
		Если Объект.DIMsUOM = CM Тогда
			КоэффициентЕдиницыИзмеренияРазмера = 1;
		Иначе
			КоэффициентЕдиницыИзмеренияРазмера = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(Объект.DIMsUOM, "ConversionFactor");
		КонецЕсли;
		
		РГСофтКлиентСервер.УстановитьЗначение(Объект.LengthCM, Объект.Length * КоэффициентЕдиницыИзмеренияРазмера);
		РГСофтКлиентСервер.УстановитьЗначение(Объект.WidthCM, Объект.Width * КоэффициентЕдиницыИзмеренияРазмера);
		РГСофтКлиентСервер.УстановитьЗначение(Объект.HeightCM, Объект.Height * КоэффициентЕдиницыИзмеренияРазмера);
		
		РГСофтКлиентСервер.УстановитьЗначение(Объект.CubicMeters, Объект.NumOfParcels * Объект.LengthCM * Объект.WidthCM * Объект.HeightCM / 1000000);
		
		// { RGS AGorlenko 09.11.2014 13:35:19 - поддержка скорректированных размеров
		РГСофтКлиентСервер.УстановитьЗначение(Объект.LengthCMCorrected, Объект.LengthCorrected * КоэффициентЕдиницыИзмеренияРазмера);
		РГСофтКлиентСервер.УстановитьЗначение(Объект.WidthCMCorrected, Объект.WidthCorrected * КоэффициентЕдиницыИзмеренияРазмера);
		РГСофтКлиентСервер.УстановитьЗначение(Объект.HeightCMCorrected, Объект.HeightCorrected * КоэффициентЕдиницыИзмеренияРазмера);
		
		РГСофтКлиентСервер.УстановитьЗначение(Объект.CubicMetersCorrected, Объект.NumOfParcels * Объект.LengthCMCorrected * Объект.WidthCMCorrected * Объект.HeightCMCorrected / 1000000);
		// } RGS AGorlenko 09.11.2014 13:35:31 - поддержка скорректированных размеров
		
	КонецЕсли; 		
	
	// Вес	
	Если ЗначениеЗаполнено(Объект.WeightUOM) Тогда
		
		Если Объект.WeightUOM = KG Тогда
			КоэффициентЕдиницыИзмеренияВеса = 1;
		Иначе
			КоэффициентЕдиницыИзмеренияВеса = РГСофтСерверПовтИспСеанс.ПолучитьЗначениеРеквизита(Объект.WeightUOM, "ConversionFactor");
		КонецЕсли;
		
		РГСофтКлиентСервер.УстановитьЗначение(Объект.GrossWeightKG, Объект.GrossWeight * КоэффициентЕдиницыИзмеренияВеса);
		// { RGS AGorlenko 09.11.2014 14:27:12 - поддержка скорректированных размеров
		РГСофтКлиентСервер.УстановитьЗначение(Объект.GrossWeightKGCorrected, Объект.GrossWeightCorrected * КоэффициентЕдиницыИзмеренияВеса);
		// } RGS AGorlenko 09.11.2014 14:27:25 - поддержка скорректированных размеров
		РГСофтКлиентСервер.УстановитьЗначение(Объект.NetWeightKG, Объект.NetWeight * КоэффициентЕдиницыИзмеренияВеса);
		
		РГСофтКлиентСервер.УстановитьЗначение(Объект.VolumeWeight, Объект.NumOfParcels * Объект.LengthCM * Объект.WidthCM * Объект.HeightCM / 6000);
		Объект.ChargeableWeight = ?(Объект.GrossWeightKG > Объект.VolumeWeight, Объект.GrossWeightKG, Объект.VolumeWeight);
		
	КонецЕсли; 	
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////
// EXPORT SHIPMENT

Процедура ЗаполнитьРеквизитыExportShipmentОбщиеДляExportRequests(ExportShipmentОбъект, ТаблицаExportRequests=Неопределено) Экспорт
	
	СтрокаСвойств = "CCA, InternationalFreightProvider, POD, POA, InternationalMOT";
	СтруктураОбщихРеквизитов = Новый Структура(СтрокаСвойств);
	
	Если ExportShipmentОбъект.ExportRequests.Количество() Тогда
		
		Если ТаблицаExportRequests = Неопределено Тогда
			
			ExportRequests = РГСофтКлиентСервер.ВыгрузитьКолонкуКоллекцииБезПустыхЗначенийИДублей(ExportShipmentОбъект.ExportRequests, "ExportRequest");
			ImportExportВызовСервера.ЗаполнитьСтруктуруОбщихРеквизитовExportRequest(СтруктураОбщихРеквизитов, ExportRequests);
			
		Иначе
			
			ImportExportВызовСервера.ЗаполнитьСтруктуруОбщихРеквизитовПоТаблице(СтруктураОбщихРеквизитов, ТаблицаExportRequests);
			
		КонецЕсли;
				
	КонецЕсли;
	
	Для Каждого КлючИЗначение из СтруктураОбщихРеквизитов Цикл 
		РГСофтКлиентСервер.УстановитьЗначение(ExportShipmentОбъект[КлючИЗначение.Ключ], КлючИЗначение.Значение);
	КонецЦикла;
	
КонецПроцедуры


Функция ПолучитьСтрокуРеквизитовCustomsFileДляShipment() Экспорт
	
	Возврат "Ссылка, No, LegalEntityCode, PermanentTemporary, RegimeCode, PSACode, CustomsValue, ReleaseDate, Comment, СтандартнаяКартинка";
	
КонецФункции