
Процедура ДобавитьОбновитьЗаписьAUsAndLegalEntities(AU, LegalEntity, Период) Экспорт 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	AUsAndLegalEntities.Период КАК Период,
		|	AUsAndLegalEntities.AU,
		|	AUsAndLegalEntities.ParentCompany,
		|	AUsAndLegalEntities.LegalEntity
		|ИЗ
		|	РегистрСведений.AUsAndLegalEntities КАК AUsAndLegalEntities
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		|			МАКСИМУМ(AUsAndLegalEntities.Период) КАК Период,
		|			AUsAndLegalEntities.AU КАК AU,
		|			AUsAndLegalEntities.ParentCompany КАК ParentCompany
		|		ИЗ
		|			РегистрСведений.AUsAndLegalEntities КАК AUsAndLegalEntities
		|		ГДЕ
		|			AUsAndLegalEntities.AU = &AU
		|			И AUsAndLegalEntities.ParentCompany = &ParentCompany
		|			И AUsAndLegalEntities.Период <= &Период
		|		
		|		СГРУППИРОВАТЬ ПО
		|			AUsAndLegalEntities.AU,
		|			AUsAndLegalEntities.ParentCompany) КАК AUsAndLegalEntitiesМаксДата
		|		ПО AUsAndLegalEntities.AU = AUsAndLegalEntitiesМаксДата.AU
		|			И AUsAndLegalEntities.ParentCompany = AUsAndLegalEntitiesМаксДата.ParentCompany
		|			И AUsAndLegalEntities.Период = AUsAndLegalEntitiesМаксДата.Период";
	
	ParentCompany = Константы.FiscalParentCompany.Получить();
	
	Запрос.УстановитьПараметр("AU", AU);
	Запрос.УстановитьПараметр("ParentCompany", ParentCompany);
	Запрос.УстановитьПараметр("Период", Период);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() тогда
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		ВыборкаДетальныеЗаписи.Следующий();
		Если LegalEntity = ВыборкаДетальныеЗаписи.LegalEntity Тогда
			Возврат;
		КонецЕсли;
		
	КонецЕсли;
	
	НаборЗаписейAUsLE = РегистрыСведений.AUsAndLegalEntities.СоздатьНаборЗаписей();
	НаборЗаписейAUsLE.Отбор.Период.Установить(Период);
	НаборЗаписейAUsLE.Отбор.AU.Установить(AU);
	НаборЗаписейAUsLE.Отбор.ParentCompany.Установить(ParentCompany);
	
	Запись = НаборЗаписейAUsLE.Добавить();
	Запись.Период = Период;
	Запись.AU = AU;
	Запись.ParentCompany = ParentCompany;
	Запись.LegalEntity = LegalEntity;
	
	//Если Не ЗначениеЗаполнено(Запись.LegalEntity) Тогда 
	//	НаборЗаписейAUsLE.Удалить(Запись);	
	//КонецЕсли;
	
	Попытка
		НаборЗаписейAUsLE.Записать();
	Исключение
		РГСофт.СообщитьИЗалоггировать(
				"Failed to write LE for AU " + СокрЛП(AU),
				УровеньЖурналаРегистрации.Ошибка,
				Метаданные.РегистрыСведений.AUsAndLegalEntities,
				Неопределено,
				ОписаниеОшибки());
	КонецПопытки;
	
КонецПроцедуры