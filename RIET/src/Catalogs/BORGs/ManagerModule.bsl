
Процедура ПодменитьAU_ACДля7BORGcodes(СтрокаТаблицы, ИмяКолонкиAU,  ИмяКолонкиActivity, BORGcode) Экспорт 
	
	//S-I-0002231
	//7D-PRU4 RU Tyumen TCS  (for site 902) -> 1069535; 
	//7F-PRU5-RU Tyumen TCS Wireline (for site 932) -> 0719535;  
	//7Q-PRUA RU Sterlitamak Perfo Co (for site 937) -> 0719534; 
	//7S-PRUB RU Moscow TCS (R&D) (for site 978) -> 5169535;   
	//7R-PRUC RU Novosibirsk TCS (R&D) (for site 979) ->2811447. 
	
	Если AUs7BORGcodes(BORGcode, СтрокаТаблицы[ИмяКолонкиAU]) Тогда  
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Код", СокрЛП(BORGcode));
		
		Запрос.Текст = "ВЫБРАТЬ
		|	BORGs.DefaultAU,
		|	BORGs.DefaultAU.DefaultActivity КАК DefaultActivity
		|ИЗ
		|	Справочник.BORGs КАК BORGs
		|ГДЕ
		|	BORGs.Код = &Код";
		
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда 
			
			СтрокаТаблицы[ИмяКолонкиAU] = Выборка.DefaultAU;
			СтрокаТаблицы[ИмяКолонкиActivity] = СокрЛП(Выборка.DefaultActivity);
			
		КонецЕсли;
		  		
	КонецЕсли;
	
КонецПроцедуры

Функция AUs7BORGcodes(BORGcode, AUCode) Экспорт
	
	//S-I-0002231
	//7D-PRU4 RU Tyumen TCS  (for site 902) -> 1069535; 
	//7F-PRU5-RU Tyumen TCS Wireline (for site 932) -> 0719535;  
	//7Q-PRUA RU Sterlitamak Perfo Co (for site 937) -> 0719534; 
	//7S-PRUB RU Moscow TCS (R&D) (for site 978) -> 5169535;   
	//7R-PRUC RU Novosibirsk TCS (R&D) (for site 979) ->2811447. 

	Возврат (СокрЛП(BORGcode) = "7D" И СтрЗаканчиваетсяНа(СокрЛП(AUCode), "902") = Истина) 		
		ИЛИ (СокрЛП(BORGcode) = "7F" И СтрЗаканчиваетсяНа(СокрЛП(AUCode), "932") = Истина) 		
		ИЛИ (СокрЛП(BORGcode) = "7Q" И СтрЗаканчиваетсяНа(СокрЛП(AUCode), "937") = Истина) 	
		ИЛИ (СокрЛП(BORGcode) = "7S" И СтрЗаканчиваетсяНа(СокрЛП(AUCode), "978") = Истина)		
		ИЛИ (СокрЛП(BORGcode) = "7R" И СтрЗаканчиваетсяНа(СокрЛП(AUCode), "979") = Истина);	
	
КонецФункции
