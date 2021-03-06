
Функция ПолучитьТаблицуДвижений(ТаблицаГеомаркетов, Дата) Экспорт
	
	ТаблицаДвижений = Неопределено;
    Отказ = Ложь;
	ДатаНачала = НачалоКвартала(Дата);
	
	ТЗ_InDom = новый ТаблицаЗначений;
	ТЗ_InDom.Колонки.Добавить("In_Dom");
	ТЗ_InDom.Колонки.Добавить("Percent");
				
		ЗапросПроценты = новый Запрос;
		ЗапросПроценты.Текст = "ВЫБРАТЬ
		|	rgsBudgetPercentageСрезПоследних.BudgetItem,
		|	rgsBudgetPercentageСрезПоследних.Percent,
		|	rgsBudgetPercentageСрезПоследних.Период,
		|	rgsBudgetPercentageСрезПоследних.BudgetItem.GroupLevel КАК GroupLevel,
		|	rgsBudgetPercentageСрезПоследних.BudgetType,
		|	rgsBudgetPercentageСрезПоследних.BudgetItem.SubLevel КАК SubLevel,
		|	rgsBudgetPercentageСрезПоследних.BudgetItem.BudgetPercentType КАК BudgetPercentType
		|ИЗ
		|	РегистрСведений.rgsBudgetPercentage.СрезПоследних(&Дата, BudgetType = &BudgetType) КАК rgsBudgetPercentageСрезПоследних";
		ЗапросПроценты.УстановитьПараметр("Дата",ДатаНачала);
	    ЗапросПроценты.УстановитьПараметр("BudgetType",Справочники.rgsBudgetType.TandM); 
		РезультатПроценты = ЗапросПроценты.Выполнить().Выгрузить();
		
		
		Для Каждого ТекСтрокаGeomarket Из ТаблицаГеомаркетов Цикл
			ТЗ_InDom.Очистить();
			Отбор = новый Структура;
			Отбор.Вставить("GroupLevel", ТекСтрокаGeomarket.Geomarket);
			Отбор.Вставить("BudgetPercentType", Перечисления.rgsBudgetPercentTypes.Sub_Geomarket);
			РезультатПроценты_Геомаркет = РезультатПроценты.Скопировать(Отбор); 
			
			Отбор = новый Структура;
			Отбор.Вставить("BudgetPercentType", Перечисления.rgsBudgetPercentTypes.InternationalDomestic);
			Отбор.Вставить("GroupLevel", ТекСтрокаGeomarket.Geomarket);
			
			РезультатПроценты_IntDom = РезультатПроценты.Скопировать(Отбор);
			
			
			Если РезультатПроценты_IntDom.Количество() > 0 тогда
				Для каждого Строка_IntDom из РезультатПроценты_IntDom цикл						
					
					СтрокаInDom = ТЗ_InDom.Добавить();
					СтрокаInDom.In_Dom = Строка_IntDom.SubLevel;
					СтрокаInDom.Percent = Строка_IntDom.Percent / 100;
					
				КонецЦикла;
			Иначе							
				Message = New UserMessage();
				Message.Text = "Нет процентов International / Domestic по " + ТекСтрокаGeomarket.Geomarket + " на дату "+ Формат(ДатаНачала, "ДФ=dd.MM.yyyy");
				Message.Message();
				Отказ = истина;	
				продолжить
			КонецЕсли;
			
			Если РезультатПроценты_Геомаркет.Количество() > 0 и РезультатПроценты_IntDom.Количество() > 0 тогда
				ТЗ_с_Геомаркетами = ТЗ_InDom.Скопировать();
				ТЗ_с_Геомаркетами.Очистить();
				ТЗ_с_Геомаркетами.Колонки.Добавить("Geomarket");
				ТЗ_с_Геомаркетами.Колонки.Добавить("SubGeomarket");
				Для каждого Строка_Geomarket из РезультатПроценты_Геомаркет цикл						
					
					Для каждого Строка_ТЗ_InDom из ТЗ_InDom цикл
						Строка_ТЗ_с_Геомаркетами = ТЗ_с_Геомаркетами.Добавить();
						Строка_ТЗ_с_Геомаркетами.In_Dom = Строка_ТЗ_InDom.In_Dom;
						Строка_ТЗ_с_Геомаркетами.Geomarket = Строка_Geomarket.GroupLevel;
						Строка_ТЗ_с_Геомаркетами.SubGeomarket = Строка_Geomarket.SubLevel;
						Строка_ТЗ_с_Геомаркетами.Percent = Строка_ТЗ_InDom.Percent * Строка_Geomarket.Percent / 100;
					КонецЦикла;
					
				КонецЦикла;
				SubGeomarkets = ТЗ_с_Геомаркетами.ВыгрузитьКолонку("SubGeomarket");	
			Иначе
				Message = New UserMessage();
				Message.Text = "Нет процентов по Субгеомаркету, Геомаркета - " + ТекСтрокаGeomarket.Geomarket + " на дату "+ Формат(ДатаНачала, "ДФ=dd.MM.yyyy");
				Message.Message();
				Отказ = истина;
				продолжить
			КонецЕсли;
			
			ЗапросСабы = новый запрос;
			ЗапросСабы.Текст = "ВЫБРАТЬ
			|	rgsBudgetPercentageСрезПоследних.Percent,
			|	rgsBudgetPercentageСрезПоследних.BudgetItem.SubLevel КАК Segment,
			|	rgsBudgetPercentageСрезПоследних.BudgetItem,
			|	rgsBudgetPercentageСрезПоследних.BudgetItem.GroupLevel КАК GroupLevel
			|ИЗ
			|	РегистрСведений.rgsBudgetPercentage.СрезПоследних(
			|			&Дата,
			|			BudgetType = &BudgetType
			|				И BudgetItem.BudgetPercentType = &BudgetPercentType
			|				И BudgetItem.GroupLevel В (&СабГеомаркеты)) КАК rgsBudgetPercentageСрезПоследних";
			ЗапросСабы.УстановитьПараметр("Дата",ДатаНачала);
	        ЗапросСабы.УстановитьПараметр("BudgetType",Справочники.rgsBudgetType.TandM);
			ЗапросСабы.УстановитьПараметр("СабГеомаркеты",SubGeomarkets);
			ЗапросСабы.УстановитьПараметр("BudgetPercentType",Перечисления.rgsBudgetPercentTypes.SubGeomarket_Segment);
			
			РезультатПроцентыСубГео_Сегмент = ЗапросСабы.Выполнить().Выгрузить(); 
			
			Если РезультатПроцентыСубГео_Сегмент.Количество() > 0 тогда
				ТЗ_с_Сегментами = ТЗ_с_Геомаркетами.Скопировать();
				ТЗ_с_Сегментами.Очистить();
				ТЗ_с_Сегментами.Колонки.Добавить("Segment");
				ТЗ_с_Сегментами.Колонки.Добавить("SubGeo_Segment");
				
				
				
				Для каждого Строка_ТЗ_с_Геомаркетами из ТЗ_с_Геомаркетами цикл
					Отбор = Новый Структура;
					Отбор.Вставить("GroupLevel", Строка_ТЗ_с_Геомаркетами.SubGeomarket);
					ПроцентыСубГео = РезультатПроцентыСубГео_Сегмент.Скопировать(Отбор);
					
					Для каждого Строка_ПроцентыСубГео_Сегмент из ПроцентыСубГео цикл
						Если ПроцентыСубГео.Количество() > 0 Тогда				
							Строка_ТЗ_с_Сегментами = ТЗ_с_Сегментами.Добавить();
							Строка_ТЗ_с_Сегментами.In_Dom = Строка_ТЗ_с_Геомаркетами.In_Dom;
							Строка_ТЗ_с_Сегментами.Geomarket = Строка_ТЗ_с_Геомаркетами.Geomarket;
							Строка_ТЗ_с_Сегментами.SubGeomarket = Строка_ТЗ_с_Геомаркетами.SubGeomarket;
							Строка_ТЗ_с_Сегментами.Segment = Строка_ПроцентыСубГео_Сегмент.Segment;
							
							Строка_ТЗ_с_Сегментами.SubGeo_Segment = Строка_ПроцентыСубГео_Сегмент.BudgetItem;
							Строка_ТЗ_с_Сегментами.Percent = Строка_ТЗ_с_Геомаркетами.Percent * Строка_ПроцентыСубГео_Сегмент.Percent / 100;
						Иначе
							Message = New UserMessage();
							Message.Text = "Нет процента для СубГеомаркета / Сегмента" + Строка_ТЗ_с_Геомаркетами.SubGem;
							Message.Message();
							Отказ = истина;
							Прервать
						КонецЕсли;
					КонецЦикла;
					
				КонецЦикла;
				СубГео_Сегмент = РезультатПроцентыСубГео_Сегмент.ВыгрузитьКолонку("BudgetItem");
				
			Иначе
				Message = New UserMessage();
				Message.Text = "Нет Сегментов, соответствующих СабГеомаркетам на дату "+ Формат(ДатаНачала, "ДФ=dd.MM.yyyy");
				Message.Message();
				Отказ = истина;
				продолжить
			КонецЕсли;
			
			
			ЗапросСабСегмент = Новый запрос;
			ЗапросСабСегмент.Текст = "ВЫБРАТЬ
			|	rgsBudgetPercentageСрезПоследних.BudgetItem.Ссылка КАК Ссылка,
			|	rgsBudgetPercentageСрезПоследних.BudgetItem.SubLevel КАК SubLevel,
			|	rgsBudgetPercentageСрезПоследних.Percent,
			|	rgsBudgetPercentageСрезПоследних.BudgetItem.GroupLevel КАК GroupLevel
			|ИЗ
			|	РегистрСведений.rgsBudgetPercentage.СрезПоследних(
			|			&Дата,
			|			BudgetType = &BudgetType
			|				И BudgetItem.BudgetPercentType = &BudgetPercentType
			|				И BudgetItem.GroupLevel В (&GroupLevel)) КАК rgsBudgetPercentageСрезПоследних";
			ЗапросСабСегмент.УстановитьПараметр("Дата",ДатаНачала);
			ЗапросСабСегмент.УстановитьПараметр("BudgetType",Справочники.rgsBudgetType.TandM);;
			ЗапросСабСегмент.УстановитьПараметр("BudgetPercentType",Перечисления.rgsBudgetPercentTypes.Sub_Segment);
			ЗапросСабСегмент.УстановитьПараметр("GroupLevel",СубГео_Сегмент);
			РезультатПроценты_СабСегмент = ЗапросСабСегмент.Выполнить().Выгрузить(); 
			
			Если РезультатПроценты_СабСегмент.Количество() > 0 тогда
				
				ТЗ_с_СабСегментами = ТЗ_с_Сегментами.Скопировать();
				ТЗ_с_СабСегментами.Очистить();
				ТЗ_с_СабСегментами.Колонки.Добавить("SubSegment");
				ТЗ_с_СабСегментами.Колонки.Добавить("Дата");
				//ТЗ_с_СабСегментами.Колонки.Добавить("Sum");
				Для каждого Строка_ТЗ_с_Сегментами из ТЗ_с_Сегментами цикл
					
					Отбор = новый структура;         
					Отбор.Вставить("GroupLevel", Строка_ТЗ_с_Сегментами.SubGeo_Segment); 
					РезультатПроценты_СабСегменты = РезультатПроценты_СабСегмент.Скопировать(Отбор);
					
					Для каждого Строка_SubSegment из РезультатПроценты_СабСегменты цикл
						Строка_ТЗ_с_СабСегментами = ТЗ_с_СабСегментами.Добавить();
						Строка_ТЗ_с_СабСегментами.In_Dom = Строка_ТЗ_с_Сегментами.In_Dom;
						Строка_ТЗ_с_СабСегментами.Geomarket = Строка_ТЗ_с_Сегментами.Geomarket;
						Строка_ТЗ_с_СабСегментами.SubGeomarket = Строка_ТЗ_с_Сегментами.SubGeomarket;
						Строка_ТЗ_с_СабСегментами.Segment = Строка_ТЗ_с_Сегментами.Segment;
						Строка_ТЗ_с_СабСегментами.SubSegment = Строка_SubSegment.SubLevel;
						Строка_ТЗ_с_СабСегментами.Percent = Строка_ТЗ_с_Сегментами.Percent * Строка_SubSegment.Percent / 100;
						Строка_ТЗ_с_СабСегментами.Дата = ДатаНачала;
						//Строка_ТЗ_с_СабСегментами.Sum = ТекСтрокаGeomarket.Sum;				
					КонецЦикла;	
					
				КонецЦикла;
				
			Иначе
				
				Message = New UserMessage();
				Message.Text = "Нет процентов по СабСегментам на дату "+ Формат(ДатаНачала, "ДФ=dd.MM.yyyy");
				Message.Message();
				Отказ = истина;
				продолжить
			КонецЕсли;
				
				Если ТаблицаДвижений = Неопределено Тогда 
					ТаблицаДвижений = Новый ТаблицаЗначений;
					ТаблицаДвижений = ТЗ_с_СабСегментами.СкопироватьКолонки();
				КонецЕсли;
			
				ДополнитьТаблицу(ТЗ_с_СабСегментами,ТаблицаДвижений)
									
		КонецЦикла;			
			
	Если НЕ Отказ Тогда
		Возврат ТаблицаДвижений
	Иначе
		Возврат ""
	КонецЕсли;
	
КонецФункции

Процедура ДополнитьТаблицу(ТаблицаИсточник, ТаблицаПриемник) Экспорт 

Для Каждого СтрокаТаблицыИсточник Из ТаблицаИсточник Цикл 

ЗаполнитьЗначенияСвойств(ТаблицаПриемник.Добавить(), СтрокаТаблицыИсточник); 

КонецЦикла; 

КонецПроцедуры

