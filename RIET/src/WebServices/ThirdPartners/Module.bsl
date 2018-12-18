
#Область ОбработчикиПодпискиНаСобытия

Функция PostDocument(СтруктураПараметровXDTO)
	
	Ответ = Новый Структура("Отказ, ТекстОшибки", Ложь, "");
	
	НачатьТранзакцию();
	
	ТекДокСтруктура = СериализаторXDTO.ПрочитатьXDTO(СтруктураПараметровXDTO);
	
	Документ = КонтрольПроведенияСервер.НайтиДокумент(ТекДокСтруктура);
	Если Документ = Неопределено Тогда
		Ответ.Отказ = Истина;
		Ответ.ТекстОшибки = "Не найден документ в базе ""Logelco""";
		ОтменитьТранзакцию();
		Возврат СериализаторXDTO.ЗаписатьXDTO(Ответ);
	КонецЕсли;
	
	Попытка
		ХешСуммаИсточник = ЗначениеИзСтрокиВнутр(ТекДокСтруктура.КонтрольнаяСумма);
		ХешСуммаПриемник = ДанныеХешСуммаПриемник(Документ, ХешСуммаИсточник);
		
		Если ХешСуммаИсточник = ХешСуммаПриемник Тогда
			Если НЕ Документ.Проведен Тогда 
				ДокументОбъект = Документ.ПолучитьОбъект();
				ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
			КонецЕсли;	
		Иначе
			Ответ.Отказ = Истина;
			Ответ.ТекстОшибки = "База Logelco: Хешсумма документа переданного ранее отличается от текущей версии!!!" + Символы.ПС 
											+ "Проверьте соответствие следующих показателей: номер, дата, контрагент, договор контрагента, валюта документа, сумма документа"; 
			ОтменитьТранзакцию();
			Возврат СериализаторXDTO.ЗаписатьXDTO(Ответ);
		КонецЕсли;
	Исключение
		Ответ.Отказ = Истина;
		МассивОшибок = ПолучитьСообщенияПользователю();
		Для каждого ЭлементМассива Из МассивОшибок Цикл
			Ответ.ТекстОшибки = Ответ.ТекстОшибки + "База Logelco: " + ЭлементМассива.Текст; 
		КонецЦикла;	
		ОтменитьТранзакцию();
		Возврат СериализаторXDTO.ЗаписатьXDTO(Ответ);
	КонецПопытки;
	
	ЗафиксироватьТранзакцию();
	
	Возврат СериализаторXDTO.ЗаписатьXDTO(Ответ);
	
КонецФункции

Функция UndoPosting(СтруктураПараметровXDTO)
	
	Ответ = Новый Структура("Отказ, ТекстОшибки", Ложь, "");
	
	НачатьТранзакцию();
	
	ТекДокСтруктура = СериализаторXDTO.ПрочитатьXDTO(СтруктураПараметровXDTO);
	
	Документ = КонтрольПроведенияСервер.НайтиДокумент(ТекДокСтруктура);
	Если Документ = Неопределено Тогда
		Ответ.Отказ = Истина;
		Ответ.ТекстОшибки = "Не найден документ в базе ""Logelco""";
		ОтменитьТранзакцию();
		Возврат СериализаторXDTO.ЗаписатьXDTO(Ответ);
	КонецЕсли;
	
	Попытка
		ХешСуммаИсточник = ЗначениеИзСтрокиВнутр(ТекДокСтруктура.КонтрольнаяСумма);
		ХешСуммаПриемник = ДанныеХешСуммаПриемник(Документ, ХешСуммаИсточник);
		
		Если ХешСуммаИсточник = ХешСуммаПриемник Тогда
			Если Документ.Проведен Тогда 
				ДокументОбъект = Документ.ПолучитьОбъект();
				ДокументОбъект.Записать(РежимЗаписиДокумента.ОтменаПроведения);
			КонецЕсли;	
		Иначе
			Ответ.Отказ = Истина;
			Ответ.ТекстОшибки = "База Logelco: Хешсумма документа переданного ранее отличается от текущей версии!!!" + Символы.ПС 
											+ "Проверьте соответствие следующих показателей: номер, дата, контрагент, договор контрагента, валюта документа, сумма документа"; 
			ОтменитьТранзакцию();
			Возврат СериализаторXDTO.ЗаписатьXDTO(Ответ);
		КонецЕсли;
	Исключение
		Ответ.Отказ = Истина;
		МассивОшибок = ПолучитьСообщенияПользователю();
		Для каждого ЭлементМассива Из МассивОшибок Цикл
			Ответ.ТекстОшибки = Ответ.ТекстОшибки + "База Logelco: " + ЭлементМассива.Текст; 
		КонецЦикла;	
		ОтменитьТранзакцию();
		Возврат СериализаторXDTO.ЗаписатьXDTO(Ответ);
	КонецПопытки;
	
	ЗафиксироватьТранзакцию();
	
	Возврат СериализаторXDTO.ЗаписатьXDTO(Ответ);
	
КонецФункции

#КонецОбласти

#Область ВспомогательныеФункции

Функция ДанныеХешСуммаПриемник(Документ, ХешСуммаИсточник)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	rgsDistributedTransaction.ХешСуммаДляСравнения
		|ИЗ
		|	РегистрСведений.rgsDistributedTransaction КАК rgsDistributedTransaction
		|ГДЕ
		|	rgsDistributedTransaction.Организация = &Организация
		|	И rgsDistributedTransaction.Документ = &Документ";
	
	Запрос.УстановитьПараметр("Документ", Документ);
	Запрос.УстановитьПараметр("Организация", Документ.Организация);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда 
		ХешСумма = Неопределено;
	Иначе
		Выборка = РезультатЗапроса.Выбрать();
		Пока Выборка.Следующий() Цикл
			ХешСумма = Выборка.ХешСуммаДляСравнения.Получить();
		КонецЦикла;
	КонецЕсли;	
	
	Возврат ХешСумма;

КонецФункции	

Процедура СформироватьПервуюЗаписьВrgsDistributedTransaction(Документ, ХешСуммаИсточник)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	rgsDistributedTransaction.ХешСуммаДляСравнения
		|ИЗ
		|	РегистрСведений.rgsDistributedTransaction КАК rgsDistributedTransaction
		|ГДЕ
		|	rgsDistributedTransaction.Организация = &Организация
		|	И rgsDistributedTransaction.Документ = &Документ";
	
	Запрос.УстановитьПараметр("Документ", Документ);
	Запрос.УстановитьПараметр("Организация", Документ.Организация);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда 
		// создаем запись при первой попытке отложенного проведения
		НоваяЗапись = РегистрыСведений.rgsDistributedTransaction.СоздатьМенеджерЗаписи();
		НоваяЗапись.Организация					= Документ.Организация;
		НоваяЗапись.Документ							= Документ;
		НоваяЗапись.ХешСуммаДляСравнения	= ХешСуммаИсточник;
		НоваяЗапись.Записать(Ложь);
	КонецЕсли;	
	
КонецПроцедуры	

Функция ДанныеДляХеширования(Ссылка)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	РеализацияТоваровУслуг.Дата,
		|	РеализацияТоваровУслуг.Номер,
		|	РеализацияТоваровУслуг.Контрагент.ВерсияДанных КАК Контрагент,
		|	РеализацияТоваровУслуг.ДоговорКонтрагента.ВерсияДанных КАК ДоговорКонтрагента,
		|	РеализацияТоваровУслуг.ВалютаДокумента.ВерсияДанных КАК ВалютаДокумента,
		|	РеализацияТоваровУслуг.СуммаДокумента КАК СуммаДокумента
		|ИЗ
		|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
		|ГДЕ
		|	РеализацияТоваровУслуг.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);

	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	СтрокаДляХеширования = "";
	Пока Выборка.Следующий() Цикл
		    СтрокаДляХеширования = СтрокаДляХеширования + Выборка.Дата + Выборка.Номер + Выборка.Контрагент + 
						Выборка.ДоговорКонтрагента + Выборка.ВалютаДокумента + Выборка.СуммаДокумента;
		
		    ХешСумма = MD5ХешСтрока(СтрокаДляХеширования);
	КонецЦикла;
	
	Возврат ХешСумма;
	
КонецФункции

Функция MD5ХешСтрока(СтрокаХеш)
	
	Хеш = Новый ХешированиеДанных(ХешФункция.MD5);
	Хеш.Добавить(СтрокаХеш);
	
	Возврат Хеш.ХешСумма;
	
КонецФункции

#КонецОбласти