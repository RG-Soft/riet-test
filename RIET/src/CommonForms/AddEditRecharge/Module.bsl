
&НаКлиенте
Процедура Ок(Команда)
	
	СписокПараметров = Новый Структура();
	СписокПараметров.Вставить("TransportRequest", TransportRequest);
	СписокПараметров.Вставить("RechargeType", RechargeType);
	СписокПараметров.Вставить("RechargeToLegalEntity", RechargeToLegalEntity);
	СписокПараметров.Вставить("RechargeToAU", RechargeToAU);
	СписокПараметров.Вставить("RechargeToActivity", RechargeToActivity);
	СписокПараметров.Вставить("ClientForRecharge", ClientForRecharge);
	СписокПараметров.Вставить("AgreementForRecharge", AgreementForRecharge);
	СписокПараметров.Вставить("RechargeDetails", RechargeDetails);
	Закрыть(СписокПараметров);
	
КонецПроцедуры

&НаКлиенте
Процедура RechargeTypeПриИзменении(Элемент)
	
	Если Элементы.InternalRecharge = ПредопределенноеЗначение("Перечисление.RechargeType.Internal") Тогда
		ClientForRecharge = Неопределено;
		AgreementForRecharge= Неопределено;
	Иначе
		RechargeToLegalEntity = Неопределено;
		RechargeToAU = Неопределено;
		RechargeToActivity = Неопределено;
	КонецЕсли;
	НастроитьВидимость();
	
КонецПроцедуры


&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Действие = "Добавление" Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest КАК TransportRequest
		|ИЗ
		|	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
		|ГДЕ
		|	TripNonLawsonCompaniesParcels.Ссылка = &Trip
		|
		|СГРУППИРОВАТЬ ПО
		|	TripNonLawsonCompaniesParcels.Parcel.TransportRequest";
		Запрос.УстановитьПараметр("Trip", Параметры.Trip);
		
		МассивTR = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("TransportRequest");
		
		Для Каждого TR Из МассивTR Цикл
			Элементы.TransportRequest.СписокВыбора.Добавить(TR);
		КонецЦикла;
		
		НовыйМассивПараметров = Новый Массив;
		НовыйМассивПараметров.Добавить(Новый ПараметрВыбора("Отбор.Ссылка", МассивTR));
		НовыеПараметрыВыбора = Новый ФиксированныйМассив(НовыйМассивПараметров);
		Элементы.TransportRequest.ПараметрыВыбора = НовыеПараметрыВыбора;
	Иначе
		Элементы.TransportRequest.Видимость = Ложь;
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, Параметры.TR);
		НастроитьВидимость();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура НастроитьВидимость()
	
	Элементы.InternalRecharge.Видимость = 
	(RechargeType = ПредопределенноеЗначение("Перечисление.RechargeType.Internal"));
	
	Элементы.ExternalRecharge.Видимость = 
	(RechargeType = ПредопределенноеЗначение("Перечисление.RechargeType.External"));
	
КонецПроцедуры

