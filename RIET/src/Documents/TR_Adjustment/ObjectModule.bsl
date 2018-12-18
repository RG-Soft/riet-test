
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	РГСофт.ЗаполнитьModification(ЭтотОбъект);
	
	Если ЭтоНовый() Тогда	
		РГСофт.ЗаполнитьCreation(ЭтотОбъект);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	ДвиженияParcelsOfTransportRequestsWithoutShipment = Движения.ParcelsOfTransportRequestsWithoutShipment;
	
	ДвиженияParcelsOfTransportRequestsWithoutShipment.Записывать = Истина;
	ДвиженияParcelsOfTransportRequestsWithoutShipment.Очистить();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.ParcelsOfTransportRequestsWithoutShipment");
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = Parcels;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных("Parcel", "Parcel");
	Блокировка.Заблокировать();
	
	Для Каждого ТекСтрокаParcels Из Parcels Цикл
		
		Остаток = Документы.TR_Adjustment.ПроверитьОстатокПоПарселю(ТекСтрокаParcels.Parcel, TR, Ссылка);
		Если Остаток = 0 Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("На текущую дату по парселю "+ ТекСтрокаParcels.Parcel +" нет остатков");
			Отказ = Истина;
		ИначеЕсли Остаток < ТекСтрокаParcels.NumOfParcels Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("По парселю  "+ ТекСтрокаParcels.Parcel +" Невозможно списать больше чем " + Остаток);
			Отказ = Истина;
		КонецЕсли;
		
		Движение = ДвиженияParcelsOfTransportRequestsWithoutShipment.ДобавитьРасход();
		Движение.Период = Дата;
		Движение.Parcel = ТекСтрокаParcels.Parcel;
		Движение.TransportRequest = TR;
		Движение.NumOfParcels = ТекСтрокаParcels.NumOfParcels;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.TransportRequest") Тогда
		
		TR = ДанныеЗаполнения.Ссылка;
		
		Выборка = Документы.TR_Adjustment.ПолучитьОстатки(TR, ТекущаяДата());
		
		Результат = Выборка.Выполнить();
		Если Не Результат.Пустой() Тогда
			Parcels.Загрузить(Результат.Выгрузить());
		Иначе
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("По выбранному TR - " + TR + " нет остатков",ЭтотОбъект);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	NewStage = РегистрыСведений.StagesOfTransportRequests.ПолучитьTransportRequestStage(TR);
	
	УстановитьПривилегированныйРежим(Истина);
	
	МенеджерЗаписи = РегистрыСведений.StagesOfTransportRequests.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.TransportRequest = TR;
	МенеджерЗаписи.Stage = NewStage;
	МенеджерЗаписи.ModificationDate = Дата;
	МенеджерЗаписи.Записать(Истина);
	
КонецПроцедуры



