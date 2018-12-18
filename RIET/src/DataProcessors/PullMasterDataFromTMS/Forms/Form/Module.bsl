
&НаКлиенте
Процедура Call(Команда)
	
	CallНаСервере(MasterDataType, Объект.TMSID);
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура CallНаСервере(MasterDataType, TMSID)
		
	Сообщить("Getting contact details of " + TMSID + "...");
	Если MasterDataType = 0 Тогда
		Структура = Обработки.PullMasterDataFromTMS.ПолучитьРеквизитыContact(TMSID);	
	ИначеЕсли MasterDataType = 1 Тогда
		Структура = Обработки.PullMasterDataFromTMS.ПолучитьРеквизитыLocation(TMSID);
	ИначеЕсли MasterDataType = 2 Тогда
		Структура = Обработки.PullMasterDataFromTMS.ПолучитьРеквизитыItem(TMSID);
	ИначеЕсли MasterDataType = 3 Тогда
		
		МассивReleaseNo = Обработки.PullMasterDataFromTMS.ПолучитьReleaseNo(TMSID);
		Для Каждого ReleaseNo Из МассивReleaseNo Цикл
			Сообщить(ReleaseNo);	
		КонецЦикла;
		Возврат;
		
	ИначеЕсли MasterDataType = 4 Тогда
		
		СтруктураShipmentNoИStatus = Обработки.PullMasterDataFromTMS.ПолучитьСтруктуруShipmentNoИStatus(TMSID);
		
		Для Каждого ShipmentNo Из СтруктураShipmentNoИStatus.МассивShipmentNo Цикл
			Сообщить(ShipmentNo);	
		КонецЦикла;
		
		Для Каждого ShipmentStatus Из СтруктураShipmentNoИStatus.МассивShipmentStatus Цикл
			Сообщить(ShipmentStatus);	
		КонецЦикла;
		Возврат;
		
	КонецЕсли;
	
	Для Каждого КлючЗначение Из Структура Цикл
		Сообщить(КлючЗначение.Ключ + ": " + КлючЗначение.Значение);	
	КонецЦикла;
					
КонецПроцедуры

&НаКлиенте
Процедура SaveQuery(Команда)
			
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);	
	ДиалогВыбораФайла.Фильтр = "XML files|*.xml";	
	Если НЕ ДиалогВыбораФайла.Выбрать() Тогда
		Возврат;
	КонецЕсли;	
	PathToXML = ДиалогВыбораФайла.ПолноеИмяФайла;
	
	АдресФайла = SaveAsXMLНаСервере(MasterDataType, Объект.TMSID);
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайла);
	ДвоичныеДанные.Записать(PathToXML);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция SaveAsXMLНаСервере(MasterDataType, TMSID)
	
	ФабрикаXDTOTMS = Обработки.PullMasterDataFromTMS.ПолучитьWSСсылку().ПолучитьWSОпределения().ФабрикаXDTO;
	
	Если MasterDataType = 0 Тогда
		Payload = Обработки.PullMasterDataFromTMS.ПолучитьPayloadForContact(ФабрикаXDTOTMS, TMSID);	
	ИначеЕсли MasterDataType = 1 Тогда
		Payload = Обработки.PullMasterDataFromTMS.ПолучитьPayloadForLocation(ФабрикаXDTOTMS, TMSID);
	ИначеЕсли MasterDataType = 2 Тогда
		Payload = Обработки.PullMasterDataFromTMS.ПолучитьPayloadForItem(ФабрикаXDTOTMS, TMSID);
	ИначеЕсли MasterDataType = 3 Тогда
		Payload = Обработки.PullMasterDataFromTMS.ПолучитьPayloadForReleaseNo(ФабрикаXDTOTMS, TMSID);
	ИначеЕсли MasterDataType = 4 Тогда
		Payload = Обработки.PullMasterDataFromTMS.ПолучитьPayloadForShipmentNo(ФабрикаXDTOTMS, TMSID);
	КонецЕсли;
		
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла("xml");
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.ОткрытьФайл(ИмяВременногоФайла);
	ФабрикаXDTOTMS.ЗаписатьXML(ЗаписьXML, Payload);
	ЗаписьXML.Закрыть();
	
	ДвоичныеДанные = Новый ДвоичныеДанные(ИмяВременногоФайла);
	
	УдалитьФайлы(ИмяВременногоФайла);
	
	Возврат ПоместитьВоВременноеХранилище(ДвоичныеДанные);
		
КонецФункции