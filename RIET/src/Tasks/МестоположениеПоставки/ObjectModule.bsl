
Процедура ОтправкаПисем()
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПарселиТрипа = Trip.Parcels.ВыгрузитьКолонку("Parcel");
	
	Водитель = Trip.Driver;
	НомерТрипа = Trip.Номер;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |	Parcels.TransportRequest.NotificationRecipients КАК NotificationRecipients,
	               |	Parcels.TransportRequest.Requestor.EMail КАК EMail,
	               |	Parcels.TransportRequest,
	               |	Parcels.TransportRequest.Номер КАК TransportRequestNo,
	               |	Parcels.TransportRequest.PickUpWarehouse КАК PickUpWarehouse,
	               |	Parcels.TransportRequest.RequiredDeliveryLocalTime КАК RDD,
	               |	Parcels.TransportRequest.DeliverTo КАК DeliverTo
	               |ИЗ
	               |	Справочник.Parcels КАК Parcels
	               |ГДЕ
	               |	Parcels.Ссылка В(&Парсели)
	               |	И НЕ Parcels.ПометкаУдаления";
	Запрос.УстановитьПараметр("Парсели", ПарселиТрипа);
	Результат = Запрос.Выполнить().Выбрать();
	
	//{ RGS AArsentev S-I-0002245 09.01.2017
	ЗапросТовары = Новый Запрос;
	ЗапросТовары.Текст = "ВЫБРАТЬ
	                     |	ParcelsДетали.СтрокаИнвойса.DescriptionRus КАК Rus,
	                     |	ParcelsДетали.СтрокаИнвойса.Ссылка КАК Инвойс,
	                     |	ParcelsДетали.СтрокаИнвойса.НаименованиеТовара КАК Eng
	                     |ИЗ
	                     |	Справочник.Parcels.Детали КАК ParcelsДетали
	                     |ГДЕ
	                     |	ParcelsДетали.Ссылка В(&Parcels)
	                     |	И НЕ ParcelsДетали.СтрокаИнвойса.ПометкаУдаления
	                     |	И НЕ ParcelsДетали.Ссылка.ПометкаУдаления";
	ЗапросТовары.УстановитьПараметр("Parcels", ПарселиТрипа);
	РезультатТовары = ЗапросТовары.Выполнить().Выгрузить();
	
	МассивТоварыRus = РезультатТовары.ВыгрузитьКолонку("Rus");
	МассивТоварыEng = РезультатТовары.ВыгрузитьКолонку("Eng");
	
	ТоварыRus = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(МассивТоварыRus, ", ");
	ТоварыEng = РГСофтКлиентСервер.ПолучитьСтрокуИзМассиваПодстрокСокрЛП(МассивТоварыEng, ", ");
	
	ОбщегоНазначения.УдалитьПовторяющиесяЭлементыМассива(ТоварыRus);
	ОбщегоНазначения.УдалитьПовторяющиесяЭлементыМассива(ТоварыEng);
	//} RGS AArsentev S-I-0002245 09.01.2017
	
	Пока Результат.Следующий() Цикл
		
		Получатели = Результат.EMail;
		Если ЗначениеЗаполнено(Результат.NotificationRecipients) Тогда
			Получатели = Получатели + "; " + Результат.NotificationRecipients;
		КонецЕсли;
		
		Копия = Trip.Operator.EMail;
		Если ПараметрыСеанса.ТекущийПользователь <> Trip.Operator Тогда 
			Копия = Копия + "; " + ПараметрыСеанса.ТекущийПользователь.EMail;
		КонецЕсли;
		
		ServiceProvider = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip, "ServiceProvider");
		
		ОписанияГрузовыхМест = ПолучитьОписаниеГрузовыхМест(Результат.TransportRequest);
		
		Тема = "Current location of " + СокрЛП(Результат.TransportRequestNo) + ", " + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Результат.PickUpWarehouse, "Наименование")) + " - " + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Результат.DeliverTo, "Наименование"));
		Тело =  "<HTML><HEAD>
		|<META content=""text/html; charset=utf-8"" http-equiv=Content-Type></META><LINK rel=stylesheet type=text/css href=""v8help://service_book/service_style""></LINK>
		|<META name=GENERATOR content=""MSHTML 11.00.9600.18538""></META><BASE href=""v8config://e0666db2-45d6-49b4-a200-061c6ba7d569/mdobject/ide9a5ee80-dd3a-418b-afb0-38339f76957d/038b5c85-fb1c-4082-9c4c-e69f8928bf3a""></BASE></HEAD>
		|<BODY>
		|<TABLE border=1>
		|<TBODY>
		|<TR style = ""padding:1.5pt 1.5pt 1.5pt 1.5pt;font-size:10pt;font-family:Tahoma,sans-serif;"">
		|<TD background-color:="" center="">Transport request:</TD>
		|<TD>" + СокрЛП(Результат.TransportRequestNo) + "</TD>
		|<TD background-color:="" center="">Заявка:</TD>
		|<TD>" + СокрЛП(Результат.TransportRequestNo) + "</TD></TR>
		
		|<TR style = ""padding:1.5pt 1.5pt 1.5pt 1.5pt;font-size:10pt;font-family:Tahoma,sans-serif;"">
		|<TD background-color:="" center="">Trip:</TD>
		|<TD>" + СокрЛП(НомерТрипа) + "</TD>
		|<TD background-color:="" center="">Поставка:</TD>
		|<TD>" + СокрЛП(НомерТрипа) + "</TD></TR>
		
		|<TR style = ""padding:1.5pt 1.5pt 1.5pt 1.5pt;font-size:10pt;font-family:Tahoma,sans-serif;"">
		|<TD background-color:="" center="">Departure place:</TD>
		|<TD>" + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Результат.PickUpWarehouse, "Наименование")) + "</TD>
		|<TD background-color:="" center="">Место отправления:</TD>
		|<TD>" + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Результат.PickUpWarehouse, "NameRus")) + "</TD></TR>
		|<TR style = ""padding:1.5pt 1.5pt 1.5pt 1.5pt;font-size:10pt;font-family:Tahoma,sans-serif;"">
		|<TD background-color:="" center="">Delivery place:</TD>
		|<TD>" + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Результат.DeliverTo, "Наименование")) + "</TD>
		|<TD background-color:="" center="">Пункт назначения:</TD>
		|<TD>" + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Результат.DeliverTo, "NameRus")) + "</TD></TR>
		//
		|<TR style = ""padding:1.5pt 1.5pt 1.5pt 1.5pt;font-size:10pt;font-family:Tahoma,sans-serif;"">
		|<TD background-color:="" center="">Service provider:</TD>
		|<TD>" + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ServiceProvider, "Наименование")) + "</TD>
		|<TD background-color:="" center="">Подрядчик:</TD>
		|<TD>" + СокрЛП(ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ServiceProvider, "NameRus")) + "</TD></TR>
		//
		|<TR style = ""padding:1.5pt 1.5pt 1.5pt 1.5pt;font-size:10pt;font-family:Tahoma,sans-serif;"">
		|<TD background-color:="" center="">Required delivery date:</TD>
		|<TD>" + СокрЛП(Результат.RDD) + "</TD>
		|<TD background-color:="" center="">Требуемое время доставки</TD>
		|<TD>" + СокрЛП(Результат.RDD) + "</TD></TR>
		|<TR style = ""padding:1.5pt 1.5pt 1.5pt 1.5pt;font-size:10pt;font-family:Tahoma,sans-serif;"">
		|<TD background-color:="" center="">Current location:</TD>
		|<TD>" + СокрЛП(Местоположение) + "</TD>
		|<TD background-color:="" center="">Текущее местоположение:</TD>
		|<TD>" + СокрЛП(Местоположение) + "</TD></TR>
		|<TR style = ""padding:1.5pt 1.5pt 1.5pt 1.5pt;font-size:10pt;font-family:Tahoma,sans-serif;"">
		|<TD background-color:="" center="">Current location time:</TD>
		|<TD>" + СокрЛП(ВремяМестоположения) + "</TD>
		|<TD background-color:="" center="">Время текущего местоположения:</TD>
		|<TD>" + СокрЛП(ВремяМестоположения) + "</TD></TR>
		//{ RGS AArsentev S-I-0002245 09.01.2017
		|<TR style = ""padding:1.5pt 1.5pt 1.5pt 1.5pt;font-size:10pt;font-family:Tahoma,sans-serif;"">
		|<TD background-color:="" center="">Items:</TD>
		|<TD>" + ТоварыEng + "</TD>
		|<TD background-color:="" center="">Товары:</TD>
		|<TD>" + ТоварыRus + "</TD></TR>
		//} RGS AArsentev S-I-0002245 09.01.2017
		
		|<TR style = ""padding:1.5pt 1.5pt 1.5pt 1.5pt;font-size:10pt;font-family:Tahoma,sans-serif;"">
		|<TD background-color:="" center="">Driver:</TD>
		|<TD>" + СокрЛП(Водитель) + "</TD>
		|<TD background-color:="" center="">Водитель:</TD>
		|<TD>" + СокрЛП(Водитель) + "</TD></TR>
		
		|<TR style = ""padding:1.5pt 1.5pt 1.5pt 1.5pt;font-size:10pt;font-family:Tahoma,sans-serif;"">
		|<TD background-color:="" center="">Parcels:</TD>
		|<TD>" + ОписанияГрузовыхМест.Eng + "</TD>
		|<TD background-color:="" center="">Грузовые места:</TD>
		|<TD>" + ОписанияГрузовыхМест.Rus + "</TD></TR>
		//
		//{ RGS AArsentev S-I-0004846 09.01.2017
		|<TR style = ""padding:1.5pt 1.5pt 1.5pt 1.5pt;font-size:10pt;font-family:Tahoma,sans-serif;"">
		|<TD background-color:="" center="">Equipment number:</TD>
		|<TD>" + ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip, "EquipmentNo") + "</TD>
		|<TD background-color:="" center="">Номер транспортного средства:</TD>
		|<TD>" + ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Trip, "EquipmentNo") + "</TD></TR>
		//} RGS AArsentev S-I-0004846 09.01.2017
		|<TR style = ""padding:1.5pt 1.5pt 1.5pt 1.5pt;font-size:10pt;font-family:Tahoma,sans-serif;"">
		|<TD background-color:="" center="">Comment:</TD>
		|<TD>" + СокрЛП(Описание) + "</TD>
		|<TD background-color:="" center="">Комментарий:</TD>
		|<TD>" + СокрЛП(Описание) + "</TD></TR>
		|</TBODY></TABLE></BODY></HTML>";
		
		РГСофт.ЗарегистрироватьПочтовоеСообщение(Получатели, Тема, Тело,,ТипТекстаПочтовогоСообщения.HTML, Копия);
		
	КонецЦикла;
	
КонецПроцедуры


Процедура ПередЗаписью(Отказ)
	
	Если ЗначениеЗаполнено(Местоположение) И ВремяМестоположения <> НачалоДня(ВремяМестоположения) И НЕ Выполнена Тогда
		
		Если ЗначениеЗаполнено(ПараметрыСеанса.ТекущийПользователь) И ПараметрыСеанса.ТекущийПользователь.Наименование <> "Не авторизован" Тогда
			СтрокаИстории = FS_History.Добавить();
			СтрокаИстории.Местоположение = Местоположение;
			СтрокаИстории.ВремяМестоположения = ВремяМестоположения;
			СтрокаИстории.User = ПараметрыСеанса.ТекущийПользователь;
			СтрокаИстории.Описание = Описание;
			ОтправкаПисем();
			
			// { RGS AArsentev 23.07.2017 S-I-0005679
			СформируемЛогиКTrip(ВремяМестоположения, Местоположение);
			// } RGS AArsentev 23.07.2017 S-I-0005679
			
		КонецЕсли;
		
	ИначеЕсли НЕ Выполнена И ЗначениеЗаполнено(ПараметрыСеанса.ТекущийПользователь) И ПараметрыСеанса.ТекущийПользователь.Наименование <> "Не авторизован"
		И ЗначениеЗаполнено(Описание) Тогда
		Если FS_History.Количество() > 0 И FS_History[FS_History.Количество() - 1].Описание <> Описание Тогда
			СтрокаИстории = FS_History.Добавить();
			СтрокаИстории.ВремяМестоположения = ТекущаяДата();
			СтрокаИстории.User = ПараметрыСеанса.ТекущийПользователь;
			СтрокаИстории.Описание = Описание;
			СформируемЛогиКTrip(ТекущаяДата(),);
		ИначеЕсли  FS_History.Количество() = 0 Тогда
			СтрокаИстории = FS_History.Добавить();
			СтрокаИстории.ВремяМестоположения = ТекущаяДата();
			СтрокаИстории.User = ПараметрыСеанса.ТекущийПользователь;
			СтрокаИстории.Описание = Описание;
			
			// { RGS AArsentev 23.07.2017 S-I-0005679
			СформируемЛогиКTrip(ТекущаяДата(),);
			// } RGS AArsentev 23.07.2017 S-I-0005679
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьОписаниеГрузовыхМест(TR)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	TripNonLawsonCompaniesParcels.Parcel.LengthCM КАК LengthCM,
	               |	TripNonLawsonCompaniesParcels.Parcel.WidthCM КАК WidthCM,
	               |	TripNonLawsonCompaniesParcels.Parcel.HeightCM КАК HeightCM,
	               |	TripNonLawsonCompaniesParcels.Parcel.PackingType КАК PackingType,
	               |	СУММА(TripNonLawsonCompaniesParcels.NumOfParcels) КАК NumOfParcels,
	               |	СУММА(TripNonLawsonCompaniesParcels.Parcel.GrossWeightKG / TripNonLawsonCompaniesParcels.Parcel.NumOfParcels * TripNonLawsonCompaniesParcels.NumOfParcels) КАК GrossWeightKG
	               |ИЗ
	               |	Документ.TripNonLawsonCompanies.Parcels КАК TripNonLawsonCompaniesParcels
	               |ГДЕ
	               |	TripNonLawsonCompaniesParcels.Ссылка = &Trip
	               |	И TripNonLawsonCompaniesParcels.Parcel.TransportRequest = &TR
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	TripNonLawsonCompaniesParcels.Parcel.PackingType,
	               |	TripNonLawsonCompaniesParcels.Parcel.LengthCM,
	               |	TripNonLawsonCompaniesParcels.Parcel.WidthCM,
	               |	TripNonLawsonCompaniesParcels.Parcel.HeightCM";
	Запрос.УстановитьПараметр("Trip",Trip);
	Запрос.УстановитьПараметр("TR",TR);
	
	ГрузовыеМеста = Запрос.Выполнить().Выгрузить();
	
	ОписанияПарселей = Новый Структура;
	
	NumOfParcels_PackingTypeEng = "";
	NumOfParcels_PackingTypeRus = "";
	
	Для Каждого Место ИЗ ГрузовыеМеста Цикл
		
		NumOfParcels_PackingTypeRus = NumOfParcels_PackingTypeRus + ?(NumOfParcels_PackingTypeRus = "", "", "; " + Символы.ПС) +
		Место.NumOfParcels + " " + РГСофт.ФормаМножественногоЧисла("упаковка", "упаковки", "упаковок", Место.NumOfParcels) + ": тип "  + """" + нрег(СокрЛП(Место.PackingType.CodeRus)) + """" + ", " + Место.LengthCM + "x" + Место.WidthCM + "x" + Место.HeightCM + " см, " + Формат(Место.GrossWeightKG, "ЧДЦ=3") + " кг";
		
	КонецЦикла;
	
	Для Каждого Место ИЗ ГрузовыеМеста Цикл
		
		NumOfParcels_PackingTypeEng = NumOfParcels_PackingTypeEng + ?(NumOfParcels_PackingTypeEng = "", "", "; " + Символы.ПС) +
		Место.NumOfParcels + " " + РГСофт.ФормаМножественногоЧисла("package", "packages", "packages", Место.NumOfParcels) + ": type "  + """" + нрег(СокрЛП(Место.PackingType.Код)) + """" + ", " + Место.LengthCM + "x" + Место.WidthCM + "x" + Место.HeightCM + " sm, " + Формат(Место.GrossWeightKG, "ЧДЦ=3") + " kg";
		
	КонецЦикла;
	
	ОписанияПарселей.Вставить("Rus", NumOfParcels_PackingTypeRus);
	ОписанияПарселей.Вставить("Eng", NumOfParcels_PackingTypeEng);
	
	Возврат ОписанияПарселей;
	
КонецФункции

// { RGS AArsentev 23.07.2017 S-I-0005679
Процедура СформируемЛогиКTrip(Время, Location = "")
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если ЗначениеЗаполнено(Location) Тогда
		ТекЛокация = ", 'Current location' - " + Location;
	КонецЕсли;
	
	МенеджерЗаписи = РегистрыСведений.TripNonLawsonCompaniesLogs.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.LogTo = Trip;
	МенеджерЗаписи.Date = ТекущаяДата();
	МенеджерЗаписи.LogType = Справочники.LogTypes.FS_Tracking;
	МенеджерЗаписи.User = ПараметрыСеанса.ТекущийПользователь;
	МенеджерЗаписи.Text = "Current location local time -" + Время + ТекЛокация + ", 'Comment' - " + Описание;
	МенеджерЗаписи.Записать();
	
	УстановитьПривилегированныйРежим(Ложь);
	
КонецПроцедуры // } RGS AArsentev 23.07.2017 S-I-0005679


