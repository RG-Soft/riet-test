
Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// { RGS LFedotova 11.10.2017 17:16:35 - вопрос S-I-0003847
	//Решено разрешать записывать только в RIET
	Если НЕ (РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() ИЛИ РГСофтСерверПовтИспСеанс.ЭтоRIET_test() ИЛИ РГСофтСерверПовтИспСеанс.ЭтоLogelco_test()) Тогда
		Сообщить("AU разрешено записывать только в базе RIET!");
		Отказ = Истина;
		Возврат;
	КонецЕсли; 
	
	//Для новых AU проверим, есть ли AU с таким же набором сегмента, субсегмента и субсубсегмента.
	//Если есть, то не записываем.
	//Проверка требуется для выявления источников записи дублей AU
	
	Если ЭтоНовый() Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	КостЦентры.Ссылка
		|ИЗ
		|	Справочник.КостЦентры КАК КостЦентры
		|ГДЕ
		|	КостЦентры.Ссылка <> &Ссылка
		|	И КостЦентры.Segment = &Segment
		|	И КостЦентры.SubSegment = &SubSegment
		|	И КостЦентры.Сегмент = &Сегмент
		|	И КостЦентры.Код = &Код";
		
		Запрос.УстановитьПараметр("Segment", Segment);
		Запрос.УстановитьПараметр("SubSegment", SubSegment);
		Запрос.УстановитьПараметр("Сегмент", Сегмент);
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Запрос.УстановитьПараметр("Код", Код);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Если ВыборкаДетальныеЗаписи.Следующий() Тогда
			Сообщить("В базе уже есть AU с кодом " + Код + ", c сегментом " + Segment + ", субсегментом " + SubSegment + 
			" и субсубсегментом " + Сегмент + ". Запись нового AU запрещена.");
			Отказ = Истина;
			Возврат;
		КонецЕсли;
	КонецЕсли; 
	// } RGS LFedotova 11.10.2017 17:22:30 - вопрос S-I-0003847
	
	// Дозаполним реквизиты без обращений к СУБД
	ДозаполнитьРеквизитыБезДополнительныхДанных();
	
	// Проверим реквизиты без обращений к СУБД
	ПроверитьРеквизитыБезДополнительныхДанных(Отказ);
	
	// Если случились ошибки - в целях оптимизации дальше ничего делать не будем
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	// Получим данные из СУБД и дозаполним реквизиты
	ДозаполнитьРеквизитыСДополнительнымиДанными();
	
	// Проверим реквизиты с учетом данных полученных из СУБД
	ПроверитьРеквизитыСДополнительнымиДанными(Отказ);
	
	//-> RG-Soft VIvanov 2015/02/18
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	ДополнительныеСвойства.Вставить("ЭтоНовый", ЭтоНовый());
	
	Если ЭтоНовый() Тогда
		Если НЕ (ДополнительныеСвойства.Свойство("ЗагрузкаИзDSS") И ДополнительныеСвойства.ЗагрузкаИзDSS) Тогда
			//-> RG-Soft VIvanov 2015/02/25
			ДополнительныеСвойства.Вставить("ЗаписатьВРегистрСегментов", Истина);
			//<-
			Запрос = Новый Запрос;
			Запрос.Текст =
			"ВЫБРАТЬ
			|	КостЦентры.Ссылка,
			|	КостЦентры.Наименование,
			|	КостЦентры.DefaultActivity,
			|	КостЦентры.OnlyMS,
			|	КостЦентры.TaxRegistration,
			|	КостЦентры.ПодразделениеОрганизации,
			|	КостЦентры.Сегмент,
			|	КостЦентры.SubSegment,
			|	КостЦентры.Segment
			|ИЗ
			|	Справочник.КостЦентры КАК КостЦентры
			|ГДЕ
			|	КостЦентры.Код = &Код";
			Запрос.УстановитьПараметр("Код", Код);
			Выборка = Запрос.Выполнить().Выбрать();
			Пока Выборка.Следующий() Цикл
				Если Наименование <> Выборка.Наименование Или DefaultActivity <> Выборка.DefaultActivity
					Или OnlyMS <> Выборка.OnlyMS Или TaxRegistration <> Выборка.TaxRegistration
					Или ПодразделениеОрганизации <> Выборка.ПодразделениеОрганизации
					//-> RG-Soft VIvanov 2015/02/25
					Или (Сегмент = Выборка.Сегмент И SubSegment = Выборка.SubSegment И Segment = Выборка.Segment) Тогда
					//<-
					
					ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не уникальный код! Accounting unit с кодом " + Код + " уже существует.", ЭтотОбъект, "Код", , Отказ);
					Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	//<- RG-Soft VIvanov
	
КонецПроцедуры

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()
	
	Код = СокрЛП(Код);
	Наименование = СокрЛП(Наименование);
	DefaultActivity = СокрЛП(DefaultActivity);
		
КонецПроцедуры

Процедура ПроверитьРеквизитыБезДополнительныхДанных(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СокрЛП(Код)) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""No."" is empty!",
			ЭтотОбъект, "Код", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Сегмент) Тогда	
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Sub sub segment"" is empty!",
			ЭтотОбъект, "Сегмент", , Отказ);	
	КонецЕсли;
	
	//{ RG-Soft добавила Петроченко НН 
	Если НЕ ЗначениеЗаполнено(Geomarket) Тогда	
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Geomarket"" is empty!",
			ЭтотОбъект, "Geomarket", , Отказ);	
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(SubGeomarket) Тогда	
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Sub geomarket"" is empty!",
			ЭтотОбъект, "SubGeomarket", , Отказ);	
	КонецЕсли; //} RG-Soft добавила Петроченко НН 

КонецПроцедуры

Процедура ДозаполнитьРеквизитыСДополнительнымиДанными()
	
	// Определим и запомним родителя саб саб сегмента
	ДополнительныеСвойства.Вставить("SubSubSegmentРодитель", Неопределено);
	Если ЗначениеЗаполнено(Сегмент) Тогда
		ДополнительныеСвойства.SubSubSegmentРодитель = ОбщегоНазначения.ПолучитьЗначениеРеквизита(Сегмент, "Родитель");
	КонецЕсли;
	
	// Дозаполним саб сегмент по родителю саб саб сегмента
	Если НЕ ЗначениеЗаполнено(SubSegment) И ЗначениеЗаполнено(ДополнительныеСвойства.SubSubSegmentРодитель) Тогда
		SubSegment = ДополнительныеСвойства.SubSubSegmentРодитель;
	КонецЕсли;
	
	// Определим и запомним родителя саб сегмента
	ДополнительныеСвойства.Вставить("SubSegmentРодитель", Неопределено);
	Если ЗначениеЗаполнено(SubSegment) Тогда
		ДополнительныеСвойства.SubSegmentРодитель = ОбщегоНазначения.ПолучитьЗначениеРеквизита(SubSegment, "Родитель");
	КонецЕсли;
	
	// Дозаполним сегмент по родителю саб сегмента
	Если НЕ ЗначениеЗаполнено(Segment) И ЗначениеЗаполнено(ДополнительныеСвойства.SubSegmentРодитель) Тогда
		Segment = ДополнительныеСвойства.SubSegmentРодитель;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(TaxRegistration) Тогда  //SLI-0005907
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		               |	СегментыКостЦентровСрезПоследних.КостЦентр.TaxRegistration КАК TaxRegistration
		               |ИЗ
		               |	РегистрСведений.СегментыКостЦентров.СрезПоследних(
		               |			&ТекДата,
		               |			Код = &Код
		               |				И КостЦентр <> &Ссылка) КАК СегментыКостЦентровСрезПоследних";
		
		Запрос.УстановитьПараметр("Код", СокрЛП(Код));
		Запрос.УстановитьПараметр("ТекДата", ТекущаяДата());
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		
		Выборка = Запрос.Выполнить().Выбрать();
		
		Если Выборка.Следующий() 
			И ЗначениеЗаполнено(Выборка.TaxRegistration) Тогда 
			TaxRegistration = Выборка.TaxRegistration;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьРеквизитыСДополнительнымиДанными(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
		
	Если ЗначениеЗаполнено(Segment) Тогда
		
		// Родителем сегмента должна быть пустая ссылка
		// Но из-за ограничения уровней иерархии эта проверка все равно так или иначе сработает
		// Поэтому в целях оптимизации - не будем ее делать
		
	Иначе
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Segment"" is empty!",
			ЭтотОбъект, "Segment", , Отказ);
			
	КонецЕсли;
	
	Если ЗначениеЗаполнено(SubSegment) Тогда
		
		// Родителем саб сегмента должен быть сегмент
		Если ЗначениеЗаполнено(Segment) Тогда
			
			Если ДополнительныеСвойства.SubSegmentРодитель <> Segment Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"""Sub segment"" does not belog to Segment!",
					ЭтотОбъект, "SubSegment", , Отказ);
			КонецЕсли;
			
		КонецЕсли;
		
	Иначе
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Sub segment"" is empty!",
			ЭтотОбъект, "SubSegment", , Отказ);
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Сегмент) Тогда
		
		// Родителем саб саб сегмента должен быть саб сегмент
		Если ЗначениеЗаполнено(SubSegment) Тогда
			
			Если ДополнительныеСвойства.SubSubSegmentРодитель <> SubSegment Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
					"""Sub sub segment"" does not belog to Sub segment!",
					ЭтотОбъект, "SubSubSegment", , Отказ);
			КонецЕсли;
			
		КонецЕсли;	
			
	Иначе
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Sub sub segment"" is empty!",
			ЭтотОбъект, "Сегмент", , Отказ);
			
	КонецЕсли;
	
	// Некоторые реквизиты могут проверяться только при интерактивной записи.
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	//Возврат;
	УстановитьПривилегированныйРежим(Истина);
	
	//-> RG-Soft VIvanov 2015/02/25
	Если Не Отказ Тогда
		Если ДополнительныеСвойства.Свойство("ЗаписатьВРегистрСегментов") И ДополнительныеСвойства.ЗаписатьВРегистрСегментов Тогда
			ЗаписьСегмента = РегистрыСведений.СегментыКостЦентров.СоздатьМенеджерЗаписи();
			ЗаписьСегмента.Период = НачалоМесяца(ТекущаяДата());
			ЗаписьСегмента.Код = Код;
			ЗаписьСегмента.КостЦентр = Ссылка;
			ЗаписьСегмента.Записать();
		КонецЕсли;
	КонецЕсли;
	//<-
	
	Если Не ЗначениеЗаполнено(TaxRegistration) Тогда
		// { RGS DKazanskiy 01.08.2018 15:11:20 - SLI-0007560
		// Если 
		Если НЕ Отказ И ОбменДанными.Загрузка и РГСофтСерверПовтИспСеанс.ЭтоProductionБазаLogelco() Тогда
			Задачи.УниверсальнаяЗадача.СоздатьЗадачуДляЗаполненияTaxRegistration(Ссылка);
		КонецЕсли;
		// } RGS DKazanskiy 01.08.2018 15:11:29 - SLI-0007560

		Возврат;
	КонецЕсли;
	    	
	LegalEntity = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(TaxRegistration, "LegalEntity");
	
	Если Не ЗначениеЗаполнено(LegalEntity) Тогда
		Возврат;
	КонецЕсли;
	
	// { RGS VChaplygin 14.04.2016 11:14:15 - SLI-0006389 Добавим для старых AU определение периода существующего
	//РегистрыСведений.AUsAndLegalEntities.ДобавитьОбновитьЗаписьAUsAndLegalEntities(Ссылка, LegalEntity, НачалоМесяца(ТекущаяДата()));
	ПериодРегистрации = НачалоМесяца(ТекущаяДата());
	Если ДополнительныеСвойства.Свойство("ЭтоНовый") И Не ДополнительныеСвойства.ЭтоНовый Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		               |	МАКСИМУМ(СегментыКостЦентров.Период) КАК Период
		               |ИЗ
		               |	РегистрСведений.СегментыКостЦентров КАК СегментыКостЦентров
		               |ГДЕ
		               |	СегментыКостЦентров.КостЦентр = &КостЦентр";
		Запрос.УстановитьПараметр("КостЦентр", Ссылка);
		
		Результат = Запрос.Выполнить();
		Если НЕ Результат.Пустой() Тогда
			Выборка = Результат.Выбрать();
			Если Выборка.Следующий() Тогда
				//Добавила Федотова Л., РГ-Софт, 19.05.16, вопрос SLI-0006480
				Если Выборка.Период = Null Тогда
					Возврат;
				КонецЕсли;
				//
				ПериодРегистрации = НачалоМесяца(Выборка.Период);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	РегистрыСведений.AUsAndLegalEntities.ДобавитьОбновитьЗаписьAUsAndLegalEntities(Ссылка, LegalEntity, ПериодРегистрации);
	// } RGS VChaplygin 14.04.2016 11:14:38 - SLI-0006389 Добавим для старых AU определение периода существующего
	
	// { RGS MYurkevich 06.04.2016 9:29:00 - 
	Если ОбменДанными.Загрузка Тогда		
		Возврат;
	КонецЕсли;
	// } RGS MYurkevich 06.04.2016 9:29:01 - 

	// { SLI-0006169 - Notification KS - Добавила Петроченко НН
	Если ДополнительныеСвойства.ЭтоНовый Тогда 
		РегистрыСведений.AUsПолучателиУведомленийКС.ДобавитьЗаписиДляНовогоAU(Ссылка);
	КонецЕсли; // } SLI-0006169 - Notification KS - конец добавления
	
КонецПроцедуры
