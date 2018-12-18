
Процедура ОбработкаПроведения(Отказ, Режим)
	
	Запрос = новый запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	rgsBudgetPercentage.BudgetType
	               |ИЗ
	               |	Документ.rgsBudgetPercentage КАК rgsBudgetPercentage
	               |ГДЕ
	               |	rgsBudgetPercentage.BudgetType = &BudgetType
	               |	И rgsBudgetPercentage.Дата МЕЖДУ &Дата1 И &Дата2
	               |	И НЕ rgsBudgetPercentage.ПометкаУдаления
	               |	И rgsBudgetPercentage.Ссылка <> &Ссылка";
	Запрос.УстановитьПараметр("Дата1",НачалоМесяца(Дата));
	Запрос.УстановитьПараметр("Дата2",КонецМесяца(Дата));
	Запрос.УстановитьПараметр("BudgetType",BudgetType);
	Запрос.УстановитьПараметр("Ссылка",Ссылка);
	Результат = Запрос.Выполнить().Выгрузить();
	Если Результат.Количество() = 0 тогда	
		// register rgsBudgetPercentage
		
		
		International_Domestic = InternationalDomestic.Выгрузить();
		SubGeomarket = Sub_Geomarket.Выгрузить();
		//Geo_Segment = GeomarketSegment.Выгрузить();
		SubSegment = Sub_Segment.Выгрузить();
		//SubGeo_Segm = SubGeo_Segment.Выгрузить();
		
		International_Domestic.Свернуть("Group_Level", "Percent");
		//Geo_Segment.Свернуть("Group_Level", "Percent");
		SubGeomarket.Свернуть("Group_Level", "Percent");
		//SubGeo_Segment.Свернуть("Group_Level", "Percent");
		
		//SubSegment.Свернуть("Group_Level", "Percent");
		
	    Для каждого СтрокаInternational_Domestic  из International_Domestic цикл
			
			Если СтрокаInternational_Domestic.Percent <> 100 тогда
				Отказ = истина;
				Message = New UserMessage();
				Message.Text = "В табличной части International Domestic сумма процентов по " +СтрокаInternational_Domestic.Group_Level+ " не равна 100";
				Message.Message();	
			КонецЕсли;
			
		КонецЦикла;
		
		Для каждого СтрокаSubGeomarket  из SubGeomarket цикл
			
			Если СтрокаSubGeomarket.Percent <> 100 тогда
				Отказ = истина;
				Message = New UserMessage();
				Message.Text = "В табличной части Sub Geomarket сумма процентов по " +СтрокаSubGeomarket.Group_Level+ " не равна 100";
				Message.Message();	
			КонецЕсли;
			
		КонецЦикла;
		
	    ТЗ_СабСегментов = Sub_Segment.Выгрузить();
		ТЗ_СабСегментов.Колонки.Добавить("Группа");
		ТЗ_СабСегментов.Колонки.Добавить("ПодГруппа");
		Для каждого строка из ТЗ_СабСегментов цикл
			строка.Группа = строка.BudgetItem.GroupLevel.GroupLevel;
			строка.ПодГруппа = строка.BudgetItem.GroupLevel.Sublevel;
		КонецЦикла;
		ТЗ_СабСегментов.Свернуть("Группа, ПодГруппа", "Percent");
		
		Для каждого СтрокаSubSegment  из ТЗ_СабСегментов цикл
			
			Если СтрокаSubSegment.Percent <> 100 тогда
				Отказ = истина;
				Message = New UserMessage();
				Message.Text = "В табличной части Sub Segment сумма процентов по " +СтрокаSubSegment.Группа+ " не равна 100";
				Message.Message();		
			КонецЕсли;
			
		КонецЦикла;
		
		
	    ТЗ_Geo_Segment = GeomarketSegment.Выгрузить();
		ТЗ_Geo_Segment.Колонки.Добавить("Группа");
		
		Для каждого строка из ТЗ_Geo_Segment цикл
			строка.Группа = строка.BudgetItem.GroupLevel;
			
		КонецЦикла;
		ТЗ_Geo_Segment.Свернуть("Группа", "Percent");
		
		Для каждого СтрокаТЗ_Geo_Segment  из ТЗ_Geo_Segment цикл
			
			Если СтрокаТЗ_Geo_Segment.Percent <> 100 тогда
				Отказ = истина;
				Message = New UserMessage();
				Message.Text = "В табличной части Geomarket Segment сумма процентов по " +СтрокаТЗ_Geo_Segment.Группа+ " не равна 100";
				Message.Message();		
			КонецЕсли;
			
		КонецЦикла;

		
		
		Для каждого СтрокаSubGeo_Segment  из SubGeo_Segment цикл
			
			Если СтрокаSubGeo_Segment.Percent = 0  тогда
				Отказ = истина;
				Message = New UserMessage();
				Message.Text = "В табличной части Sub geomarket segment имеется нулевое значение процента";
				Message.Message();		
			КонецЕсли;
			
		КонецЦикла;
		
				
		Движения.rgsBudgetPercentage.Записывать = Истина;
		Движения.rgsBudgetPercentage.Очистить();
		Для Каждого ТекСтрокаInternationalDomestic Из InternationalDomestic Цикл
			Движение = Движения.rgsBudgetPercentage.Добавить();
			Движение.Период = Дата;
			Движение.BudgetType = BudgetType;
			Движение.BudgetItem = ТекСтрокаInternationalDomestic.BudgetItem;
			Движение.Percent = ТекСтрокаInternationalDomestic.Percent;
		КонецЦикла;
		
		Для Каждого ТекСтрокаSub_Geomarket Из Sub_Geomarket Цикл
			Движение = Движения.rgsBudgetPercentage.Добавить();
			Движение.Период = Дата;
			Движение.BudgetType = BudgetType;
			Движение.BudgetItem = ТекСтрокаSub_Geomarket.BudgetItem;
			Движение.Percent = ТекСтрокаSub_Geomarket.Percent;
		КонецЦикла;
		
		Для Каждого ТекСтрокаSub_Segment Из Sub_Segment Цикл
			Движение = Движения.rgsBudgetPercentage.Добавить();
			Движение.Период = Дата;
			Движение.BudgetType = BudgetType;
			Движение.BudgetItem = ТекСтрокаSub_Segment.BudgetItem;
			Движение.Percent = ТекСтрокаSub_Segment.Percent;
		КонецЦикла;
		
		Для Каждого ТекСтрокаSubGeo_Segment Из SubGeo_Segment Цикл
			Движение = Движения.rgsBudgetPercentage.Добавить();
			Движение.Период = Дата;
			Движение.BudgetType = BudgetType;
			Движение.BudgetItem = ТекСтрокаSubGeo_Segment.BudgetItem;
			Движение.Percent = ТекСтрокаSubGeo_Segment.Percent;
		КонецЦикла;
				
		Для Каждого ТекСтрокаGeomarketSegment Из GeomarketSegment Цикл
			Движение = Движения.rgsBudgetPercentage.Добавить();
			Движение.Период = Дата;
			Движение.BudgetType = BudgetType;
			Движение.BudgetItem = ТекСтрокаGeomarketSegment.BudgetItem;
			Движение.Percent = ТекСтрокаGeomarketSegment.Percent;
		КонецЦикла;
		
		Для Каждого ТекСтрокаRevenueProcent Из RevenueProcent Цикл
			Движение = Движения.rgsBudgetPercentage.Добавить();
			Движение.Период = Дата;
			Движение.BudgetType = BudgetType;
			Движение.BudgetItem = ТекСтрокаRevenueProcent.BudgetItem;
			Движение.Percent = ТекСтрокаRevenueProcent.Percent;
		КонецЦикла;
		
		
	Иначе
		Отказ = Истина;
		Message = New UserMessage();
		Message.Text = "В этом месяце уже был проведен документ бюджетирования";
		Message.Message();	
	КонецЕсли;
	
	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Дата = НачалоМесяца(Дата);
	
	ModifiedBy = ПараметрыСеанса.ТекущийПользователь;
	ModificationDate = ТекущаяДата();
	
КонецПроцедуры

