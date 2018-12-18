
Функция ПолучитьПоКоду(Код) Экспорт
	
	// Возвращает ссылку, ищет по Коду
	// Отсекает помеченные на удаление, если найдено несколько возвращает Неопределено
	// Рекомендуется вызывать из модуля с повторным использованием значений
	
	Возврат РГСофт.НайтиСсылку("Справочник", "SLSRCA", "Код", Код);
	
КонецФункции

Функция ПолучитьМассивSLSEmailsBySegmentProcessLevel(Segment, ProcessLevel) Экспорт 
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Segment", Segment);
	Запрос.УстановитьПараметр("ProcessLevel", ProcessLevel);

	Запрос.Текст = "ВЫБРАТЬ
	               |	SLSRCAProcessLevels.Ссылка КАК SLSRCA
	               |ПОМЕСТИТЬ SLSRCAProcessLevels
	               |ИЗ
	               |	Справочник.SLSRCA.ProcessLevels КАК SLSRCAProcessLevels
	               |ГДЕ
	               |	SLSRCAProcessLevels.ProcessLevel = &ProcessLevel
	               |	И НЕ SLSRCAProcessLevels.Ссылка.ПометкаУдаления
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	SLSRCASegments.Ссылка КАК SLSRCA
	               |ПОМЕСТИТЬ SLSRCASegments
	               |ИЗ
	               |	Справочник.SLSRCA.Segments КАК SLSRCASegments
	               |ГДЕ
	               |	НЕ SLSRCASegments.Ссылка.ПометкаУдаления
	               |	И SLSRCASegments.Segment = &Segment
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	SLSRCA.EMail КАК EMail
	               |ИЗ
	               |	Справочник.SLSRCA КАК SLSRCA
	               |ГДЕ
	               |	SLSRCA.Ссылка В
	               |			(ВЫБРАТЬ
	               |				SLSRCAProcessLevels.SLSRCA
	               |			ИЗ
	               |				SLSRCAProcessLevels КАК SLSRCAProcessLevels)
	               |	И SLSRCA.Ссылка В
	               |			(ВЫБРАТЬ
	               |				SLSRCASegments.SLSRCA
	               |			ИЗ
	               |				SLSRCASegments КАК SLSRCASegments)";
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("EMail");
	
КонецФункции