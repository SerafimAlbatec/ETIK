class EticController < ApplicationController

    ## Kati gia session
	skip_before_filter :verify_authenticity_token, :only => [:update]

    ## Για καθε url που παταω με το χερι, δεν πηγενει το site γιατι πρεπει πρωτα να κανεις log in.
    ## Εκτος αν αλλαξω γλωσσα που γίνεται και στην αρχικη σελιδα του log in.
	before_action :authenticate_user!, except: [:language, :contact, :send_mail]

    ## Αλλαγη γλωσσας. Γενικα εχω ένα session[:locale] απο το application_controller.
    ## Αν αλλαξει η γλωσσα την αλλαζω με τα if. 
	def language
	  if ( params[:lang] == "en" )
	    I18n.locale = 'en'
	    session[:locale] = "en"
	  end
	  if ( params[:lang] == "gr" )
	    I18n.locale = 'gr'
	    session[:locale] = "gr"
	  end
	  if ( params[:lang] == "de" )
	    I18n.locale = 'de'
	    session[:locale] = "de"
	  end
	  I18n.locale = session[:locale]
	  if current_user
	  	redirect_to :back
	  else
	  	redirect_to root_path
	  end
	end

    ## CONTACT: Η σελίδα που βλέπω όταν πατάω contact στην μπαρα
    ## SEND_MAIL: Η μέθοδος που στέλνει mail στον admin. UserMailer -> class, welcome_email -> method
	def contact
	end

	def send_mail
		user_info = {:email_user => params[:email], :username => params[:onoma], :number => params[:arithmos], :message => params[:koimeno], :aiteria => params[:company], :epitheto => params[:surname]} 
        UserMailer.welcome_email(user_info).deliver #this will deliver the mail
        #redirect_to root_path, alert: "Watch it, mister!"
	end

    ## Μέθοδος που καλείτε απο το view etic_card όταν παταω + σε κουφωμα για νέο χρήστη.
    ## Κραταει το id του pseudo user που πατησα + σε καθοληκή μεταβλητή $pseUserId  
	def pse_user
		$pseUserId = params[:pse_user]
		redirect_to etic_home_path
	end

	def simple_pse_user
		#$pseUserId_2 = params[:pse_user]
		$paraggelia_simple = params[:paraggelia_id]
		redirect_to etic_home_path
	end

    ## Αρχική σελίδα μετα το log in. 
    ## Παραθέτω ολα τα ανοίγματα.
	def home
		@cat_anoigmatos = OpenCategorie.all
	end

    ## Κρατάω ολες τις μεταβήτές που εχω ήδη πατήσει απο πριν με @.
    ## Διχνω ολα τα υλικά 
    ## Το σύμβολο ? ειναι για να δημιουργήσω url με το back button του browser.
    ## Έχω πρόβλημα με το back, κανει κατι ακαταλαβήστηκα.
    ## Η σελίδα αυτη χρησιμοποιεί τις μεθόδους kataskevastes, system, line και παίρνει δεδομένα απο αυτες σε json φορματ
	def material
		@open_categorie = params[:open_categorie]
        @uliko = Material.all
        @sumbol = "?"
	end

	def kataskevastes
		# 1 Constructor εχει πολλα materials, material_constructors ενδιάμεσος
		# Πατοντας στο υλικο ψαχνω τους κατασκεβαστες
		@kata = Constructor.joins(:material_constructors, :materials).where(["material_constructors.material_id = ? AND materials.id = ?", params[:material_id], params[:material_id]])
		#Κάνω join τους πινακες που θέλω και εχω στοιχεια πανω σε αυτον που θελω να παρω τις εγγραφες. 
		#Περνω τις εγγραφες με κοινα id 
		respond_to do |format|
          format.json { render json: @kata.to_json}
        end
	end

	def system
		##### ΛΑΘΟΣ 1 CONSTRUCTOR ΕΧΕΙ ΠΟΛΛΑ ΣΥΣΤΗΜΑΤΑ....ΘΑ ΓΙΝΕΙ ΟΠΩΣ ΑΠΟ ΚΑΤΩ ΠΟΥ ΨΑΧΝΩ ΤΑ ΠΟΛΛΑ ΚΑΙ ΟΧΙ ΤΟ 1
		@system = System.where(:constructor_id => params[:constructor_id])
		respond_to do |format|
          format.json { render json: @system.to_json}
        end
	end

	def line
		# 1 συστημα εχει πολλες γραμμες. Περνάω το id του συστηματος και το ψαννω στον ενδιάμεσο πινακα
		#Απλα εδω ψανχω τις γραμμες(τα πολλα) και οχι το συστημα(το 1) οπως πανω
		@line = Line.joins(:system_lines).where(["system_lines.system_id = ?", params[:system_id]])
		respond_to do |format|
          format.json { render json: @line.to_json}
        end
	end

    ## Η σελίδα αυτή εμφανίζει την επιλογή φύλλων.
    ## Κρατάω ολες τις μεταβήτές που εχω ήδη πατήσει απο πριν με @.
    ## Το σύμβολο ? ειναι για να δημιουργήσω url με το back button του browser.
    ## Έχω πρόβλημα με το back, κανει κατι ακαταλαβήστηκα.
	def leaf
		@sumbol = "?"
		@open_categorie_name = params[:open_categorie_name]
		@open_categorie = OpenCategorie.where(:name => params[:open_categorie_name]).first
		@material = Material.where(:id => params[:material_id]).first
		@constructor = Constructor.where(:id => params[:constructor_id]).first
		@system = System.where(:id => params[:system_id]).first
		@line = Line.where(:id => params[:line_id]).first
		####
		@leaf = Leaf.joins(:open_categorie_leafs).where(["open_categorie_leafs.open_categorie_id = ?", @open_categorie.id])
	end

    ## Σε αυτην την σελίδα προβάλω τους τύπους ανοίγματος.
    ## Αρχικα κάνω το join τα open_type με τα line 
    ## Και μετά απο αυτα που βρηκα διαλέγω αυτα με τα αντιστοιχα φυλλα και κατηγορια που διαλεξα. 
	def open_type
		@open_categorie = OpenCategorie.where(:name => params[:open_categorie_name]).first
		@material = Material.where(:name => params[:material_name]).first
		@constructor = Constructor.where(:name => params[:constructor_name]).first
		@system = System.where(:name => params[:system_name]).first
		@line = Line.where(:name => params[:line_name]).first
		@leaf = Leaf.where(:name => params[:leaf_name]).first
		##
		@open_type = OpenType.joins(:system_open_types).where(["system_open_types.line_id = ?", @line.id]).order(:order)
		@open_type1 = @open_type.where(:leaf_id => @leaf.id, :open_categorie_id => @open_categorie.id)
        
	end

    ## Εμφανίζω τα color ανάλωγα με την κατηγορία. Αυτη η σελίδα χρησιμοποιει και τις μεθοδους
    ## color_kasas και color_fulou. Αν αλλάξουν τα χρώματα απλα κάνω ενα νέο πινακα και συνδέω αυτον.
	def color
		@open_categorie = OpenCategorie.where(:name => params[:open_categorie_name]).first
		@material = Material.where(:name => params[:material_name]).first
		@constructor = Constructor.where(:name => params[:constructor_name]).first
		@system = System.where(:name => params[:system_name]).first
		@line = Line.where(:name => params[:line_name]).first
		@leaf = Leaf.where(:name => params[:leaf_name]).first
		@open_type = OpenType.where(:name => params[:open_type_name]).first
		##
		@colors_0 = Color.where(:katigoria => 0)
		@colors_standar = Color.where(:katigoria => 1)
		@colors_extra = Color.where(:katigoria => 2)
	end

	def corol_kasas
		@colors = Color.all
		respond_to do |format|
          format.json { render json: @colors.to_json}
        end
	end

	def color_fulou
		@colors = Color.all
		respond_to do |format|
          format.json { render json: @colors.to_json}
        end
	end

    ## Σε αυτην την σελίδα δίνω με @ ολες τις μεταβλητές που χρειάζονται στο πινακακι αριστερα.
    ## Ακόμη δίνω το max και min, width και height.
	def diastaseis
        @open_categorie = OpenCategorie.where(:name => params[:open_categorie_name]).first
		@material = Material.where(:name => params[:material_name]).first
		@constructor = Constructor.where(:name => params[:constructor_name]).first
		@system = System.where(:name => params[:system_name]).first
		@line = Line.where(:name => params[:line_name]).first
		@leaf = Leaf.where(:name => params[:leaf_name]).first
		@open_type = OpenType.where(:name => params[:open_type_name]).first
		@color = Color.where(:name => params[:color_name]).first
		@mesa_eksw = params[:mesa_eksw]
		##if params exists ΚΑΝΟΝΙΚΑ
		@color_deksia = Color.where(:name => params[:coldeksia]).first
		@color_aristera = Color.where(:name => params[:colaristera]).first
		@color_panw = Color.where(:name => params[:colpanw]).first
		@color_katw = Color.where(:name => params[:colkatw]).first
		@color_fulou = Color.where(:name => params[:colfullo]).first
		########
		@max_width = @open_type.max_width
		@min_width = @open_type.min_width
		@max_height = @open_type.max_height
		@min_height = @open_type.min_height
	end

    ## Η σελίδα extra προβάλει όλα τα extra που μπορει να πάρει ένα κούφωμα. 
    ## Αρχικά δίνω τα extra που θέλω.
    ## Μετά δίνω αυτα που πάτησα απο πρίν για το πινακάκι το κόκκινο.
    ## Η σελίδα αυτη χρισημοποιεί τις παρακάτω μεθόδους --->
    ## epikathimena, color_epikathimenou, eksoterika, color_eksoterikou, color_persidas, color_odoigou, tzamia, color_typos, color_profil.
    ## Όλες αυτές τις μεθόδους τις έχω για να πέρνω δεδομένα σε json format.
	def extra
		@epikathimena_cat = Epikathimeno.all
		@eksoteriko_cat = Eksoterika.all
		@persides = Persides.all
		@cat_tzamia = CatTzamia.all
		@typos = Profil.where(:width => 0)
		@profil = Profil.where.not(:width => 0)
		@roll_guide = RollGuide.all
		@order = Order.where(:id => params[:order]).first
		if !@order.nil?
			@order = Order.where(:id => params[:order]).first
		else
			@order = 0
		end
		if params.has_key?(:pse_user)
			$pseUserId = params[:pse_user]
		end
		if params.has_key?(:paraggelia_id)
			$paraggelia_simple = params[:paraggelia_id]
		end

        ##Κοκκινο πινακάκι
		@open_categorie = OpenCategorie.where(:name => params[:open_categorie_name]).first
		@material = Material.where(:name => params[:material_name]).first
		@constructor = Constructor.where(:name => params[:constructor_name]).first
		@system = System.where(:name => params[:system_name]).first
		@line = Line.where(:name => params[:line_name]).first
		@leaf = Leaf.where(:name => params[:leaf_name]).first
		@open_type = OpenType.where(:name => params[:open_type_name]).first
		@color = Color.where(:name => params[:color_name]).first
		@mesa_eksw = params[:mesa_eksw]
		@xwrisma1 = params[:xwrisma1]
		@xwrisma2 = params[:xwrisma2]
		@xwrisma3_1 = params[:xwrisma3_1]
		@xwrisma3_2 = params[:xwrisma3_2]
		@xwrisma3_3 = params[:xwrisma3_3]
		@xwrisma_y_1 = params[:xwrisma_y_1]
		@xwrisma_y_2 = params[:xwrisma_y_2]
		## if params exists ΚΑΝΟΝΙΚΑ
		@color_deksia = Color.where(:name => params[:color_deksia]).first
		@color_aristera = Color.where(:name => params[:color_aristera]).first
		@color_panw = Color.where(:name => params[:color_panw]).first
		@color_katw = Color.where(:name => params[:color_katw]).first
		@color_fulou = Color.where(:name => params[:color_fulou]).first
		@posotita = 1#params[:posotita].to_i
		## Το $height και $width δεν τα χρησιμοποιώ λογικά!!
		@lastixo = params[:lastixo]
		@width = params[:width]
		@height = params[:height]
		width = params[:width].to_f
		$width = width
		@width_new = width
		height = params[:height].to_f
		$height = height
		@height_new = height 
	end

	def epikathimena
		##Me ajax na pernw epikath an kanw click se epikath
		@epikathimena = RolaEpik.where(:epikathimeno_id => params[:epikathimeno_cat])
		respond_to do |format|
          format.json { render json: @epikathimena.to_json}
        end
	end

	def color_epikathimenou
		@colors = RolaColor.all
		respond_to do |format|
          format.json { render json: @colors.to_json}
        end
	end

	def eksoterika
		##Me ajax na pernw epikath an kanw click se epikath
		@eksoterika = RolaEkso.where(:rola_ekso_id => params[:eksoteriko_cat])
		respond_to do |format|
          format.json { render json: @eksoterika.to_json}
        end
	end

	def color_eksoterikou
		@colors = RolaColor.all
		respond_to do |format|
          format.json { render json: @colors.to_json}
        end
	end

	def color_persidas
		@color_persidas = RolaColor.all
		respond_to do |format|
          format.json { render json: @color_persidas.to_json}
        end
	end

	def color_odoigou
		@color_odoigou = RolaColor.all
		respond_to do |format|
          format.json { render json: @color_odoigou.to_json}
        end
	end

	def tzamia 
		@tzamia = Tzamia.where(:cat_tzamia_id => params[:id])
		respond_to do |format|
          format.json { render json: @tzamia.to_json}
        end
	end

	def color_typos
		@color_typos = RolaColor.all
		respond_to do |format|
          format.json { render json: @color_typos.to_json}
        end
	end

	def profil
		@profil = Profil.where.not(:width => 0)
		respond_to do |format|
          format.json { render json: @profil.to_json}
        end
	end

	def color_profil
		@color_profil = RolaColor.all
		respond_to do |format|
          format.json { render json: @color_profil.to_json}
        end
	end

    ## Μονο για επικαθήμενα. Βλέπω αν οι διαστάσεις είναι σωστές και αφήνω ή όχι τα χρώματα των επικαθήμενων να εμφανιστούν.
    ## Δεν ξέρω αν χρειάζονται όλα αυτα για το view, ίσως δεν περνάω αρκετα στοιχεια απο ajax.
    ## Πάντα η μέθοδος δέχετε τις νέες διαστάσεις και οχι τις αρχικές.
	def upologismos
		
        @epikathimena_cat = Epikathimeno.all
         
		@open_categorie = OpenCategorie.where(:name => params[:open_categorie_name]).first
		@material = Material.where(:name => params[:material_name]).first
		@constructor = Constructor.where(:name => params[:constructor_name]).first
		@system = System.where(:name => params[:system_name]).first
		@line = Line.where(:name => params[:line_name]).first
		@leaf = Leaf.where(:name => params[:leaf_name]).first
		@open_type = OpenType.where(:name => params[:open_type_name]).first
		@color = Color.where(:name => params[:color_name]).first
		##if params exists ΚΑΝΟΝΙΚΑ
		@color_deksia = Color.where(:name => params[:color_deksia]).first
		@color_aristera = Color.where(:name => params[:color_aristera]).first
		@color_panw = Color.where(:name => params[:color_panw]).first
		@color_katw = Color.where(:name => params[:color_katw]).first
		@color_fulou = Color.where(:name => params[:color_fulou]).first
		@posotita = params[:posotita].to_i
		##
		@width = params[:width]
		@height = params[:height_new]
		width = params[:width].to_f
		height = params[:height_new].to_f
		############
		@epikathimeno = RolaEpik.where(:id => params[:epikathimeno_rolo]).first
		@anoigma = OpenType.where(:name => params[:anoigma]).first
		@height = params[:height_new]##POU EDWSA
        
		@min = @anoigma.min_height
		@mion = ( height - @epikathimeno.height )
        ## Αν το min height του κουφωματος είναι μικρότερο απο το νέο height(height που έδωσα - ρολό), τοτε όλα σωστα.
        ## Αλλιώς δεν παράγετε τόσο μικρό κούφωμα και δεν μπορούμε να βάλουμε επικαθημενο ρολο.
		if ( @min <= @mion )##swsto ΥΠΟΛΟΓΙΣΜΟΣ ΝΕΑΣ ΤΙΜΗΣ + ΠΡΟΒΟΛΗ
			@apantisi = true
			respond_to do |format|
	          format.json { render json: @apantisi}
	        end
		end
		if ( @min > @mion )##akuro
			@apantisi = false
			respond_to do |format|
	          format.json { render json: @apantisi}
	        end
		end
	end

    ## Στις δυο παρακάτω μεθόδους βλέπω αν χωράει το προφιλ δεξια και αριστερά.
    ## Πάντα η μέθοδος δέχετε τις νέες διαστάσεις και οχι τις αρχικές. 
	def upologismos_platos_profil
		@profil = Profil.where(:id => params[:profil]).first
		@anoigma = OpenType.where(:name => params[:anoigma]).first
		@width = params[:width_new]##POU EDWSA
		width = params[:width_new].to_f
		input = params[:input].to_i

		@min = @anoigma.min_width
		@mion = ( width - (@profil.width * input) )

		if ( @min <= @mion )##swsto ΥΠΟΛΟΓΙΣΜΟΣ ΝΕΑΣ ΤΙΜΗΣ + ΠΡΟΒΟΛΗ
			@apantisi = true
			respond_to do |format|
	          format.json { render json: @apantisi}
	        end
		end
		if ( @min > @mion )##akuro  Ετσι παμε στο προιγουμενο width, αυτο που εδωσα στον ajax
			@apantisi = false
			respond_to do |format|
	          format.json { render json: @apantisi}
	        end
		end
	end

	def upologismos_upsos_profil
		@profil = Profil.where(:id => params[:profil]).first
		@anoigma = OpenType.where(:name => params[:anoigma]).first
		@height = params[:height_new]##POU EDWSA
		height = params[:height_new].to_f
		input = params[:input].to_i

		@min = @anoigma.min_height
		@mion = ( height - (@profil.height * input) )

		if ( @min <= @mion )##swsto ΥΠΟΛΟΓΙΣΜΟΣ ΝΕΑΣ ΤΙΜΗΣ + ΠΡΟΒΟΛΗ
			@apantisi = true
			respond_to do |format|
	          format.json { render json: @apantisi}
	        end
		end
		if ( @min > @mion )##akuro
			@apantisi = false
			respond_to do |format|
	          format.json { render json: @apantisi}
	        end
		end
	end

    ############# Να πρωσθέσω μια ενδιαμεση συναρτηση που να κανει την δουλεια του price  ######
    ############# Δεν χρησιμοποιω το view price που ειναι η γενικη παραγγελια ######
    ## Γενικά η price είναι η μέθοδος που υπολογίζει όλες τις τιμές ανάλογα σε πιο σημίο είμαστε.
    ## Κάνει και τελικό υπολογισμό και σταδικά προσθέτει τιμές ανάλογα με το τι προσθέτουμε.
	def price
		@open_categorie = OpenCategorie.where(:name => params[:open_categorie_name]).first
		@material = Material.where(:name => params[:material_name]).first
		@constructor = Constructor.where(:name => params[:constructor_name]).first
		@system = System.where(:name => params[:system_name]).first
		@line = Line.where(:name => params[:line_name]).first
		@leaf = Leaf.where(:name => params[:leaf_name]).first
		@open_type = OpenType.where(:name => params[:open_type_name]).first
		@color = Color.where(:name => params[:color_name]).first
		@mesa_eksw = params[:mesa_eksw]
		##if params exists ΚΑΝΟΝΙΚΑ
		@color_deksia = Color.where(:name => params[:color_deksia]).first
		@color_aristera = Color.where(:name => params[:color_aristera]).first
		@color_panw = Color.where(:name => params[:color_panw]).first
		@color_katw = Color.where(:name => params[:color_katw]).first
		@color_fulou = Color.where(:name => params[:color_fulou]).first
		@posotita = params[:posotita].to_i
		## Ρολα
		@odoigos = RollGuide.where(:id => params[:odoigos_rolou]).first
		@xrwma_odoigou = params[:color_odoigou]
		@tzamia = Tzamia.where(:id => params[:tzamia]).first
		@epik_rolo = RolaEpik.where(:id => params[:epik_rolo]).first
		@xrwma_epikathimenou = params[:xrwma_epikathimenou]
		@ekso_rolo = RolaEkso.where(:id => params[:ekso_rolo]).first
		@xrwma_eksoterikou = params[:xrwma_eksoterikou]
		@persida = Persides.where(:id => params[:persida]).first
		@xrwma_persidas = params[:color_persidas]
		@lastixo = params[:lastixo]
		#### NEA PROFIL
		@profil_deksia_1 = Profil.where(:id => params[:profil_deksia_1]).first
		@numero_deksia_1 = params[:profil_deksia_1_arithmos].to_i
		#@timi_profil_deksia_1 = ( @profil_deksia_1.price * @numero_deksia_1 )
		@profil_deksia_2 = Profil.where(:id => params[:profil_deksia_2]).first
		@numero_deksia_2 = params[:profil_deksia_2_arithmos].to_i
		#@timi_profil_deksia_2 = ( @profil_deksia_2.price * @numero_deksia_2 )
		@profil_deksia_3 = Profil.where(:id => params[:profil_deksia_3]).first
		@numero_deksia_3 = params[:profil_deksia_3_arithmos].to_i
		#@timi_profil_deksia_3 = ( @profil_deksia_3.price * @numero_deksia_3 )
		@profil_aristera_1 = Profil.where(:id => params[:profil_aristera_1]).first
		@numero_aristera_1 = params[:profil_aristera_1_arithmos].to_i
		#@timi_profil_deksia_1 = ( @profil_deksia_1.price * @numero_deksia_1 )
		@profil_aristera_2 = Profil.where(:id => params[:profil_aristera_2]).first
		@numero_aristera_2 = params[:profil_aristera_2_arithmos].to_i
		#@timi_profil_deksia_2 = ( @profil_deksia_2.price * @numero_deksia_2 )
		@profil_aristera_3 = Profil.where(:id => params[:profil_aristera_3]).first
		@numero_aristera_3 = params[:profil_aristera_3_arithmos].to_i
		#@timi_profil_deksia_3 = ( @profil_deksia_3.price * @numero_deksia_3 )
		@profil_panw_1 = Profil.where(:id => params[:profil_panw_1]).first
		@numero_panw_1 = params[:profil_panw_1_arithmos].to_i
		#@timi_profil_deksia_1 = ( @profil_deksia_1.price * @numero_deksia_1 )
		@profil_panw_2 = Profil.where(:id => params[:profil_panw_2]).first
		@numero_panw_2 = params[:profil_panw_2_arithmos].to_i
		#@timi_profil_deksia_2 = ( @profil_deksia_2.price * @numero_deksia_2 )
		@profil_panw_3 = Profil.where(:id => params[:profil_panw_3]).first
		@numero_panw_3 = params[:profil_panw_3_arithmos].to_i
		########
		@profil_katw_1 = Profil.where(:id => params[:profil_katw_1]).first
		@numero_katw_1 = params[:profil_katw_1_arithmos].to_i
		#@timi_profil_deksia_1 = ( @profil_deksia_1.price * @numero_deksia_1 )
		@profil_katw_2 = Profil.where(:id => params[:profil_katw_2]).first
		@numero_katw_2 = params[:profil_katw_2_arithmos].to_i
		#@timi_profil_deksia_2 = ( @profil_deksia_2.price * @numero_deksia_2 )
		@profil_katw_3 = Profil.where(:id => params[:profil_katw_3]).first
		@numero_katw_3 = params[:profil_katw_3_arithmos].to_i
		########
		@typos_katw_1 = Profil.where(:id => params[:typos_katw_1]).first
		@numero_typos_1 = params[:typos_katw_1_arithmos].to_i
		#@timi_profil_deksia_1 = ( @profil_deksia_1.price * @numero_deksia_1 )
		@typos_katw_2 = Profil.where(:id => params[:typos_katw_2]).first
		@numero_typos_2 = params[:typos_katw_2_arithmos].to_i
		#@timi_profil_deksia_2 = ( @profil_deksia_2.price * @numero_deksia_2 )
		@typos_katw_3 = Profil.where(:id => params[:typos_katw_3]).first
		@numero_typos_3 = params[:typos_katw_3_arithmos].to_i
		### Μεχρι εδω
		@numero_deksia = params[:posotita_deksia_profil].to_i
		@numero_aristera = params[:posotita_aristera_profil].to_i
		@numero_panw = params[:posotita_panw_profil].to_i
		@numero_katw = params[:posotita_katw_profil].to_i
		@color_profil_deksia = RolaColor.where(:name => params[:color_profil_deksia]).first 
		@color_profil_aristera = RolaColor.where(:name => params[:color_profil_aristera]).first
		@color_profil_panw = RolaColor.where(:name => params[:color_profil_panw]).first
		@color_profil_katw = RolaColor.where(:name => params[:color_profil_katw]).first
		#@typos = Profil.where(:id => params[:typos]).first
		#@color_typos = RolaColor.where(:name => params[:color_typos]).first
		##
		@width = params[:width]
		@height = params[:height]
		width = params[:width].to_f
		height = params[:height].to_f
		xwrisma1 = params[:xwrisma1]
		xwrisma2 = params[:xwrisma2]
		xwrisma3_1 = params[:xwrisma3_1]
		xwrisma3_2 = params[:xwrisma3_2]
		xwrisma3_3 = params[:xwrisma3_3]
		xwrisma_y_1 = params[:xwrisma_y_1]
		xwrisma_y_2 = params[:xwrisma_y_2]
		width_neo = params[:new_width].to_f
		height_neo = params[:new_height].to_f
        ### Μεχρι εδώ είναι για view που δεν χρησιμοποιώ.

        ## HASH με διακυμάνσεις τιμών σύμφωνα με την βάση μου.
        ## Ανάλογα με το μίκος και ύψος, που πάτησα ψαχνω μεσα σε αυτα τα hash και πέρνω μια τιμή, το κλειδί. 
        widths = { 600 => (350..700), 701 => (701..800), 801 => (801..900), 901 => (901..1000), 1001 => (1001..1100), 1101 => (1101..1200), 1201 => (1201..1300), 1301 => (1301..1400), 1401 => (1401..1500), 1501 => (1501..1600), 1601 => (1601..1700), 1701 => (1701..1800), 1801 => (1801..1900), 1901 => (1901..2000), 2001 => (2001..2100), 2101 => (2101..2200), 2201 => (2201..2300), 2301 => (2301..2400), 2401 => (2401..2500), 2501 => (2501..2600), 2601 => (2601..2700), 2701 => (2701..2800), 2801 => (2801..2900), 2901 => (2901..3000), 3001 => (3001..3100)}
        heights = { 600 => (350..700), 701 => (701..800), 801 => (801..900), 901 => (901..1000), 1001 => (1001..1100), 1101 => (1101..1200), 1201 => (1201..1300), 1301 => (1301..1400), 1401 => (1401..1500), 1501 => (1501..1600), 1601 => (1601..1700), 1701 => (1701..1800), 1801 => (1801..1900), 1901 => (1901..2000), 2001 => (2001..2100), 2101 => (2101..2200), 2201 => (2201..2300), 2301 => (2301..2400), 2401 => (2401..2500), 2501 => (2501..2600), 2601 => (2601..2700), 2701 => (2701..2800), 2801 => (2801..2900), 2901 => (2901..3000), 3001 => (3001..3100), 3101 => (3101..3200), 3201 => (3201..3300), 3301 => (3301..3400), 3401 => (3401..3500), 3501 => (3501..3600), 3701 => (3701..3800), 3801 => (3801..3900), 3901 => (3901..4000), 4001 => (4001..4101)}
        
        width_index = widths.select do |k,v|
		  v.include?(width)
		end.keys.first

		height_index = heights.select do |c,d|
		  d.include?(height)
		end.keys.first

        ### Και πιο κάτω, έγινε αλλαγη για να τεριάζει στην βάση!!
		if (@open_type.code == 6 || @open_type.code == 6.1 || @open_type.code == 7) 
			if width <= 1000 
				width_index = 700
			end
		end
		if (@open_type.code == 8 || @open_type.code == 8.1 || @open_type.code == 9 || @open_type.code == 10) 
			if width <= 1200 
				width_index = 1201
			end
		end
		if (@open_type.code == 11 || @open_type.code == 11.1) 
			if width <= 1500 
				width_index = 1501
			end
		end
		if (@open_type.code == 12 || @open_type.code == 12.1 || @open_type.code == 13) 
			if width <= 2100 
				width_index = 2101
			end
		end
		if (@open_type.code == 14 || @open_type.code == 14.1 || @open_type.code == 15) 
			if height <= 1300 
				height_index = 1301
			end
		end
		if (@open_type.code == 16 || @open_type.code == 16.1 || @open_type.code == 17) 
			if width <= 1200 
				width_index = 1201
			end
			if height <= 1500 
				height_index = 1501
			end
		end
		if (@open_type.code == 18 ) 
			if width <= 1200 
				width_index = 1201
			end
			if height <= 1400 
				height_index = 1401
			end
		end
		## Μπαλκονια
		if (@open_type.code == 19 || @open_type.code == 20 ) 
			if width <= 700 
				width_index = 701
			end
			if height <= 1900 
				height_index = 1901
			end
		end
		if (@open_type.code == 21 ) 
			if width <= 700 
				width_index = 701
			end
			if height <= 2400 
				height_index = 2401
			end
		end
		if (@open_type.code == 22 || @open_type.code == 23 || @open_type.code == 23.1 || @open_type.code == 24 || @open_type.code == 27 ) 
			if width <= 1200 
				width_index = 1201
			end
			if height <= 1900 
				height_index = 1901
			end
		end
		if (@open_type.code == 25 || @open_type.code == 26 || @open_type.code == 26.1 ) 
			if width <= 2001 
				width_index = 2001
			end
			if height <= 1900 
				height_index = 1901
			end
		end


        ##Γενικη τιμη. Η τιμή χωρίς έξτρα. Μονο επιβάρινση γραμμης, λάστιχού και χρώματος. 
        #@price_temp = @open_type.send("h#{height_index}p#{width_index}".to_sym)
        @price_temp = Pricelist.where(:code => @open_type.code, :width => width_index, :height => height_index).first.price

        ## ΕΠΙΒΑΡΙΝΣΗ ΓΡΑΜΜΗΣ
        @price_temp = @price_temp + (@price_temp * (@line.epivarinsi_line / 100))
        ## ΕΠΙΒΑΡΙΝΣΗ ΛΑΣΤΙΧΟΥ
        @price_temp = @price_temp + (@price_temp * (@line.epivarinsi_lastixo / 100))


        ################## Επιβαρινση χρωματων ################
        ################# Αν δεν εχω εχτρα χρωματα
        if ( @mesa_eksw == '2' )
          ep = @color.duo_pleura
        elsif ( @mesa_eksw == '1'  )
          ep = @color.mia_pleura
        end
        ################# Αν εχω και τα 2 εχτρα κια για τις 2 πλευρες
        if (@mesa_eksw == '1' && !@color_deksia.nil? && !@color_fulou.nil?)
          color_array = [@color_deksia.mia_pleura, @color_aristera.mia_pleura, @color_panw.mia_pleura, @color_katw.mia_pleura, @color_fulou.mia_pleura, @color.mia_pleura ]
          ep = color_array[color_array.index(color_array.compact.max)]
        elsif (@mesa_eksw == '2' && !@color_deksia.nil? && !@color_fulou.nil?)
          color_array = [@color_deksia.duo_pleura, @color_aristera.duo_pleura, @color_panw.duo_pleura, @color_katw.duo_pleura, @color_fulou.duo_pleura ]
          ep = color_array[color_array.index(color_array.compact.max)]
        ################# Αν εχω μονο χρωματα κασας
        elsif (@mesa_eksw == '1' && !@color_deksia.nil? && @color_fulou.nil?)
          color_array = [@color_deksia.mia_pleura, @color_aristera.mia_pleura, @color_panw.mia_pleura, @color_katw.mia_pleura, @color.mia_pleura ]
          ep = color_array[color_array.index(color_array.compact.max)]
        elsif (@mesa_eksw == '2' && !@color_deksia.nil? && @color_fulou.nil?)
          color_array = [@color_deksia.duo_pleura, @color_aristera.duo_pleura, @color_panw.duo_pleura, @color_katw.duo_pleura ]
          ep = color_array[color_array.index(color_array.compact.max)]
          ################# Αν εχω μονο χρωματα φυλου
        elsif (@mesa_eksw == '1' && @color_deksia.nil? && !@color_fulou.nil?)
          color_array = [@color_fulou.mia_pleura, @color.mia_pleura ]
          ep = color_array[color_array.index(color_array.compact.max)]
        elsif (@mesa_eksw == '2' && @color_deksia.nil? && !@color_fulou.nil?)
          color_array = [@color_fulou.duo_pleura, @color.duo_pleura ]
          ep = color_array[color_array.index(color_array.compact.max)]
        end

        ## ΤΙΜΗ ΧΩΡΙΣ ΕΧΤΡΑ ΑΠΛΗ = price.
        @price = @price_temp + ( @price_temp * (ep / 100) )

        ####  ETXRA  #################
        ## Νεοι υπολογισμοι γιατι μπορει να αλλαζουν οι διαστασεις. Πάλι απο την αρχή.(height_neo, width_neo.)
        ## Η αρχική τιμή χωρίς εξτρα δεν αλλάζει. Ειναι price.
        height_index = heights.select do |c,d|
			  d.include?(height_neo)
			end.keys.first
		width_index = widths.select do |k,v|
		  v.include?(width_neo)
		end.keys.first	

		if (@open_type.code == 6 || @open_type.code == 6.1 || @open_type.code == 7) 
			if width_neo <= 1000 
				width_index = 700
			end
		end
		if (@open_type.code === 8 || @open_type.code === 8.1 || @open_type.code === 9 || @open_type.code === 10) 
			if width_neo <= 1200 
				width_index = 1201
			end
		end
		if (@open_type.code === 11 || @open_type.code === 11.1) 
			if width_neo <= 1500 
				width_index = 1501
			end
		end
		if (@open_type.code === 12 || @open_type.code === 12.1 || @open_type.code === 13) 
			if width_neo <= 2100 
				width_index = 2101
			end
		end
		if (@open_type.code === 14 || @open_type.code === 14.1 || @open_type.code === 15) 
			if height_neo <= 1300 
				height_index = 1301
			end
		end
		if (@open_type.code == 16 || @open_type.code == 16.1 || @open_type.code == 17) 
			if width_neo <= 1200 
				width_index = 1201
			end
			if height_neo <= 1500 
				height_index = 1501
			end
		end
		if (@open_type.code == 18 ) 
			if width_neo <= 1200 
				width_index = 1201
			end
			if height_neo <= 1400 
				height_index = 1401
			end
		end
		## Μπαλκονια
		if (@open_type.code == 19 || @open_type.code == 20 ) 
			if width_neo <= 700 
				width_index = 701
			end
			if height_neo <= 1900 
				height_index = 1901
			end
		end
		if (@open_type.code == 21 ) 
			if width_neo <= 700 
				width_index = 701
			end
			if height_neo <= 2400 
				height_index = 2401
			end
		end
		if (@open_type.code == 22 || @open_type.code == 23 || @open_type.code == 23.1 || @open_type.code == 24 || @open_type.code == 27 ) 
			if width_neo <= 1200 
				width_index = 1201
			end
			if height_neo <= 1900 
				height_index = 1901
			end
		end
		if (@open_type.code == 25 || @open_type.code == 26 || @open_type.code == 26.1 ) 
			if width_neo <= 2001 
				width_index = 2001
			end
			if height_neo <= 1900 
				height_index = 1901
			end
		end

		@price_temp = Pricelist.where(:code => @open_type.code, :width => width_index, :height => height_index).first.price
	        
	    ## ΕΠΙΒΑΡΙΝΣΗ ΓΡΑΜΜΗΣ
	    @price_temp = @price_temp + (@price_temp * (@line.epivarinsi_line / 100))
	    ## ΕΠΙΒΑΡΙΝΣΗ ΛΑΣΤΙΧΟΥ
	    @price_temp = @price_temp + (@price_temp * (@line.epivarinsi_lastixo / 100))

       #######EXTRA #############
       ## price extra ειναι μονο η τιμη ολων των εχτρας μαζι
       @price_extra = 0
       ## Price new ειναι η τιμη του κουφωματος με τις νεες διστασεις
       @price_new = 0
       ##Me xrwmata. Πέρνω το ep που το έχω απο πριν.
	   @price_new = @price_temp + ( @price_temp * (ep / 100) )

        ## Εδώ προσθέτω στην price_extra όλα τα extra που επιλέγω. 
	    ## TIMI ME ROLA MONO tzamia
	    if ( !@tzamia.nil? )
	    	@price_extra = @price_extra + @tzamia.price.to_f
	    end

	    if ( !@odoigos.nil? )
	    	@price_extra = @price_extra + @odoigos.price.to_f
	    end

        ##TIMI ME ROLA MONO EPIKATHIMENO
	    if ( !@epik_rolo.nil? )
	    	@price_extra = @price_extra + @epik_rolo.price.to_f
	    end
        
        ##TIMI ME ROLA MONO EKSOTERIKO
        if ( !@ekso_rolo.nil? )
        	@price_extra = @price_extra + @ekso_rolo.price.to_f
        end

        ##ΤΙΜΗ ΜΕ ΠΕΡΣΙΔΑ
        if ( !@persida.nil? )
          @price_extra = @price_extra + @persida.price
        end
        
        ##TIMH ME ΠΡΟΦΙΛ
        profil_sum = 0


        ### Νεα προφιλ
        if ( !@profil_deksia_1.nil? )
          @price_extra = @price_extra + ( @profil_deksia_1.price * @numero_deksia_1 )
          profil_sum = profil_sum + ( @profil_deksia_1.price * @numero_deksia_1 )
        end
        if ( !@profil_deksia_2.nil? )
          @price_extra = @price_extra + ( @profil_deksia_2.price * @numero_deksia_2 )
          profil_sum = profil_sum + ( @profil_deksia_2.price * @numero_deksia_2 )
        end
        if ( !@profil_deksia_3.nil? )
          @price_extra = @price_extra + ( @profil_deksia_3.price * @numero_deksia_3 )
          profil_sum = profil_sum + ( @profil_deksia_3.price * @numero_deksia_3 )
        end

        if ( !@profil_aristera_1.nil? )
          @price_extra = @price_extra + ( @profil_aristera_1.price * @numero_aristera_1 )
          profil_sum = profil_sum + ( @profil_aristera_1.price * @numero_aristera_1 )
        end
        if ( !@profil_aristera_2.nil? )
          @price_extra = @price_extra + ( @profil_aristera_2.price * @numero_aristera_2 )
          profil_sum = profil_sum + ( @profil_aristera_2.price * @numero_aristera_2 )
        end
        if ( !@profil_aristera_3.nil? )
          @price_extra = @price_extra + ( @profil_aristera_3.price * @numero_aristera_3 )
          profil_sum = profil_sum + ( @profil_aristera_3.price * @numero_aristera_3 )
        end

        if ( !@profil_panw_1.nil? )
          @price_extra = @price_extra + ( @profil_panw_1.price * @numero_panw_1 )
          profil_sum = profil_sum + ( @profil_panw_1.price * @numero_panw_1 )
        end
        if ( !@profil_panw_2.nil? )
          @price_extra = @price_extra + ( @profil_panw_2.price * @numero_panw_2 )
          profil_sum = profil_sum + ( @profil_panw_2.price * @numero_panw_2 )
        end
        if ( !@profil_panw_3.nil? )
          @price_extra = @price_extra + ( @profil_panw_3.price * @numero_panw_3 )
          profil_sum = profil_sum + ( @profil_panw_3.price * @numero_panw_3 )
        end

        if ( !@profil_katw_1.nil? )
          @price_extra = @price_extra + ( @profil_katw_1.price * @numero_katw_1 )
          profil_sum = profil_sum + ( @profil_katw_1.price * @numero_katw_1 )
        end
        if ( !@profil_katw_2.nil? )
          @price_extra = @price_extra + ( @profil_katw_2.price * @numero_katw_2 )
          profil_sum = profil_sum + ( @profil_katw_2.price * @numero_katw_2 )
        end
        if ( !@profil_katw_3.nil? )
          @price_extra = @price_extra + ( @profil_katw_3.price * @numero_katw_3 )
          profil_sum = profil_sum + ( @profil_katw_3.price * @numero_katw_3 )
        end

        if ( !@typos_katw_1.nil? )
          @price_extra = @price_extra + ( @typos_katw_1.price * @numero_typos_1 )
          profil_sum = profil_sum + ( @typos_katw_1.price * @numero_typos_1 )
        end
        if ( !@typos_katw_2.nil? )
          @price_extra = @price_extra + ( @typos_katw_2.price * @numero_typos_2 )
          profil_sum = profil_sum + ( @typos_katw_2.price * @numero_typos_2 )
        end
        if ( !@typos_katw_3.nil? )
          @price_extra = @price_extra + ( @typos_katw_3.price * @numero_typos_3 )
          profil_sum = profil_sum + ( @typos_katw_3.price * @numero_typos_3 )
        end

        ### Μεχρι εδω


        ##### ΤΕΛΙΚΗ ΤΙΜΗ ########### Και οι δυο οι τιμες μαζι. Εδω παντα θα ειναι η δευτερη
        if ( @price_new == 0)
          @price_sum = @price + @price_extra
        else
          @price_sum = @price_new + @price_extra	
        end

        ## Εδώ αν το αίτημα είναι html μπορω να αποθηκεύσω στην βάση την παραγγελία.
        if request.format.html?
	        ##Eggrafi paraggelias ston pinaka
	        @order = Order.new()
		    @order.open_categorie_id = @open_categorie.name
		    @order.material_id = @material.name
		    @order.constructor_id = @constructor.name
		    @order.system_id = @system.name
		    @order.line_id = @line.name
		    @order.leaf_id = @leaf.id
		    @order.main_color_id = @color.name
		    @order.in_out = @mesa_eksw
		    @order.open_type_id = @open_type.name
		    @order.image = @open_type.image # + ".png"
		    #### ΧΡΩΜΑΤΑ
		    if !@color_fulou.nil?
		      @order.leaf_color_id = @color_fulou.name
		    end
		    if !@color_deksia.nil?
			  @order.right_color_id = @color_deksia.name
		      @order.left_color_id = @color_aristera.name
			  @order.up_color_id = @color_panw.name
			  @order.down_color_id = @color_katw.name
		    end
		    #### ΔΙΑΣΤΑΣΕΙΣ
		    @order.width = @width
		    @order.width_new = width_neo
		    if ( !xwrisma1.nil? && xwrisma1 != "0" )
		    	@order.xwrisma1 = xwrisma1
		    	@order.xwrisma2 = xwrisma2
		    end
		    if ( !xwrisma3_1.nil? && xwrisma3_1 != "0" )
		    	@order.xwrisma3_1 = xwrisma3_1
		    	@order.xwrisma3_2 = xwrisma3_2
		    	@order.xwrisma3_3 = xwrisma3_3
		    end
		    if ( !xwrisma_y_1.nil? && xwrisma_y_1 != "0" )
		    	@order.xwrisma_y_1 = xwrisma_y_1
		    	@order.xwrisma_y_2 = xwrisma_y_2
		    end
		    @order.height_new = height_neo
		    @order.height = @height
		    #if !@epik_rolo.nil?
		    #  @order.height_new = @height_new
		    #end
		    #### ΛΑΣΤΙΧΟ
		    if !@lastixo.nil?
		      @order.lastixo = @lastixo
		    end
		    #### EXTRA
		    if !@tzamia.nil?
		      @order.tzamia = @tzamia.name
		      @order.price_tzamiou = @tzamia.price.to_f
		    end
		    if !@odoigos.nil?
		    	@order.odoigos = @odoigos.name
		    	@order.color_odoigou = @xrwma_odoigou
		    	@order.price_odoigou = @odoigos.price.to_f
		    end
		    if !@epik_rolo.nil?
		      @order.rolo = @epik_rolo.name
		      @order.color_rolou = @xrwma_epikathimenou
		      @order.price_rolou = @epik_rolo.price.to_f
		    end
		    if !@ekso_rolo.nil?
		      @order.rolo = @ekso_rolo.name
		      @order.color_rolou = @xrwma_eksoterikou
		      @order.price_rolou = @ekso_rolo.price.to_f
		     end
		    if !@persida.nil?
		    	@order.persida = @persida.name
		    	@order.color_persidas = @xrwma_persidas
		    	@order.price_persidas = @persida.price
		    end
		    ### Nea profil
		    if !@profil_deksia_1.nil?
		    	@order.profil_deksia_1 = @profil_deksia_1.name
		    	@order.color_profil_d = @color_profil_deksia.name
		    	@order.profil_deksia_arithmos_1 = @numero_deksia_1
		    	@order.timi_profil_deksia_1 = ( @profil_deksia_1.price * @numero_deksia_1 )
		    end
		    if !@profil_deksia_2.nil?
		    	@order.profil_deksia_2 = @profil_deksia_2.name
		    	@order.color_profil_d = @color_profil_deksia.name
		    	@order.profil_deksia_arithmos_2 = @numero_deksia_2
		    	@order.timi_profil_deksia_2 = ( @profil_deksia_2.price * @numero_deksia_2 )
		    end
		    if !@profil_deksia_3.nil?
		    	@order.profil_deksia_3 = @profil_deksia_3.name
		    	@order.color_profil_d = @color_profil_deksia.name
		    	@order.profil_deksia_arithmos_3 = @numero_deksia_3
		    	@order.timi_deksia_profil_3 = ( @profil_deksia_3.price * @numero_deksia_3 )
		    end

		    if !@profil_aristera_1.nil?
		    	@order.profil_aristera_1 = @profil_aristera_1.name
		    	@order.color_profil_a = @color_profil_aristera.name
		    	@order.profil_aristera_arithmos_1 = @numero_aristera_1
		    	@order.timi_profil_aristera_1 = ( @profil_aristera_1.price * @numero_aristera_1 )
		    end
		    if !@profil_aristera_2.nil?
		    	@order.profil_aristera_2 = @profil_aristera_2.name
		    	@order.color_profil_a = @color_profil_aristera.name
		    	@order.profil_aristera_arithmos_2 = @numero_aristera_2
		    	@order.timi_profil_aristera_2 = ( @profil_aristera_2.price * @numero_aristera_2 )
		    end
		    if !@profil_aristera_3.nil?
		    	@order.profil_aristera_3 = @profil_aristera_3.name
		    	@order.color_profil_a = @color_profil_aristera.name
		    	@order.profil_aristera_arithmos_3 = @numero_aristera_3
		    	@order.timi_profil_aristera_3 = ( @profil_aristera_3.price * @numero_aristera_3 )
		    end

		    if !@profil_panw_1.nil?
		    	@order.profil_panw_1 = @profil_panw_1.name
		    	@order.color_profil_p = @color_profil_panw.name
		    	@order.profil_panw_arithmos_1 = @numero_panw_1
		    	@order.timi_profil_panw_1 = ( @profil_panw_1.price * @numero_panw_1 )
		    end
		    if !@profil_panw_2.nil?
		    	@order.profil_panw_2 = @profil_panw_2.name
		    	@order.color_profil_p = @color_profil_panw.name
		    	@order.profil_panw_arithmos_2 = @numero_panw_2
		    	@order.timi_profil_panw_2 = ( @profil_panw_2.price * @numero_panw_2 )
		    end
		    if !@profil_panw_3.nil?
		    	@order.profil_panw_3 = @profil_panw_3.name
		    	@order.color_profil_p = @color_profil_panw.name
		    	@order.profil_panw_arithmos_3 = @numero_panw_3
		    	@order.timi_profil_panw_3 = ( @profil_panw_3.price * @numero_panw_3 )
		    end

		    if !@profil_katw_1.nil?
		    	@order.profil_katw_1 = @profil_katw_1.name
		    	@order.color_profil_k = @color_profil_katw.name
		    	@order.profil_katw_arithmos_1 = @numero_katw_1
		    	@order.timi_profil_katw_1 = ( @profil_katw_1.price * @numero_katw_1 )
		    end
		    if !@profil_katw_2.nil?
		    	@order.profil_katw_2 = @profil_katw_2.name
		    	@order.color_profil_k = @color_profil_katw.name
		    	@order.profil_katw_arithmos_2 = @numero_katw_2
		    	@order.timi_profil_katw_2 = ( @profil_katw_2.price * @numero_katw_2 )
		    end
		    if !@profil_katw_3.nil?
		    	@order.profil_katw_3 = @profil_katw_3.name
		    	@order.color_profil_k = @color_profil_katw.name
		    	@order.profil_katw_arithmos_3 = @numero_katw_3
		    	@order.timi_profil_katw_3 = ( @profil_katw_3.price * @numero_katw_3 )
		    end

		    if !@typos_katw_1.nil?
		    	@order.typos_katw_1 = @typos_katw_1.name
		    	@order.color_profil_k = @color_profil_katw.name
		    	@order.typos_katw_arithmos_1 = @numero_typos_1
		    	@order.timi_typos_katw_1 = ( @typos_katw_1.price * @numero_typos_1 )
		    end
		    if !@typos_katw_2.nil?
		    	@order.typos_katw_2 = @typos_katw_2.name
		    	@order.color_profil_k = @color_profil_katw.name
		    	@order.typos_katw_arithmos_2 = @numero_typos_2
		    	@order.timi_typos_katw_2 = ( @typos_katw_2.price * @numero_typos_2 )
		    end
		    if !@typos_katw_3.nil?
		    	@order.typos_katw_3 = @typos_katw_3.name
		    	@order.color_profil_k = @color_profil_katw.name
		    	@order.typos_katw_arithmos_3 = @numero_typos_3
		    	@order.timi_typos_katw_3 = ( @typos_katw_3.price * @numero_typos_3 )
		    end

		    ####Mexri edw
		   

		    #### ΤΙΜΕΣ
		    #### price, price_update, price_extra, price_sum, price_new
		    @order.price = @price
		    @order.price_extra = @price_extra
		    @order.price_new = @price_new
		    @order.price_sum = @price_sum
		    @order.price_update = @price_sum
		    @order.posotoita = @posotita
		    #### USER
		    if current_user.admin == 1
		      user = PseUser.where(:id => $pseUserId).first
		        if ( user )
			      @order.user_id = user.id
			      @order.pse = 1
			    else
		          @order.user_id = current_user.id
		          @order.pse = 0
		        end
		    else
		      @order.paraggelia_id = $paraggelia_simple
		      @order.user_id = current_user.id
		      @order.pse = 0
		    end
		    last = Order.order("created_at").last
		    id_canvas = last.id + 1
		    @order.canvas = id_canvas
		    @order.save 
		    #@order.canvas = @order.id
		end

        ## Αλλάζω τα ονόματα των μεταβλητών για να τα δέχετε καλήτερα η javascript.
        if !@epik_rolo.nil?
        	epik_rolo_name = @epik_rolo.name
        	epik_rolo_price = @epik_rolo.price
        else
        	epik_rolo_name = ""
        	epik_rolo_price = 0
        end
        if !@ekso_rolo.nil?
        	ekso_rolo_name = @ekso_rolo.name
        	ekso_rolo_price = @ekso_rolo.price
        else
        	ekso_rolo_name = ""
        	ekso_rolo_price = 0
        end
        if !@persida.nil?
        	persida_name = @persida.name
        	persida_price = @persida.price
        else
        	persida_name = ""
        	persida_price = 0
        end
        if !@tzamia.nil?
        	tzami_name = @tzamia.name
        	tzami_timi = @tzamia.price
        else
        	tzami_name = ""
        	tzami_timi = 0
        end
        if !@odoigos.nil?
        	odoigos_name = @odoigos.name
        	odoigos_timi = @odoigos.price
        else
        	odoigos_name = ""
        	odoigos_timi = 0
        end
        profil_price = 0
        profil_posotita = 0
        if !@profil_deksia_1.nil? 
        	profil_name_deksia_1 = @profil_deksia_1.name
        	profil_price_deksia_1 = (@profil_deksia_1.price * @numero_deksia_1)
        	profil_posotita_deksia_1  = @numero_deksia_1
        else
        	profil_name_deksia_1 = ""
        	profil_price_deksia_1 = 0
        	profil_posotita_deksia_1 = 0
        end
        if !@profil_deksia_2.nil? 
        	profil_name_deksia_2 = @profil_deksia_2.name
        	profil_price_deksia_2 = (@profil_deksia_2.price * @numero_deksia_2)
        	profil_posotita_deksia_2 =  @numero_deksia_2
        else
        	profil_name_deksia_2 = ""
        	profil_price_deksia_2 = 0
        	profil_posotita_deksia_2 = 0
        end
        if !@profil_deksia_3.nil? 
        	profil_name_deksia_3 = @profil_deksia_3.name
        	profil_price_deksia_3 = (@profil_deksia_3.price * @numero_deksia_3)
        	profil_posotita_deksia_3 =  @numero_deksia_3
        else
        	profil_name_deksia_3 = ""
        	profil_price_deksia_3 = 0
        	profil_posotita_deksia_3 = 0
        end

        if !@profil_aristera_1.nil? 
        	profil_name_aristera_1 = @profil_aristera_1.name
        	profil_price_aristera_1 = (@profil_aristera_1.price * @numero_aristera_1)
        	profil_posotita_aristera_1  = @numero_aristera_1
        else
        	profil_name_aristera_1 = ""
        	profil_price_aristera_1 = 0
        	profil_posotita_aristera_1 = 0
        end
        if !@profil_aristera_2.nil? 
        	profil_name_aristera_2 = @profil_aristera_2.name
        	profil_price_aristera_2 = (@profil_aristera_2.price * @numero_aristera_2)
        	profil_posotita_aristera_2 =  @numero_aristera_2
        else
        	profil_name_aristera_2 = ""
        	profil_price_aristera_2 = 0
        	profil_posotita_aristera_2 = 0
        end
        if !@profil_aristera_3.nil? 
        	profil_name_aristera_3 = @profil_aristera_3.name
        	profil_price_aristera_3 = (@profil_aristera_3.price * @numero_aristera_3)
        	profil_posotita_aristera_3 =  @numero_aristera_3
        else
        	profil_name_aristera_3 = ""
        	profil_price_aristera_3 = 0
        	profil_posotita_aristera_3 = 0
        end
        if !@profil_panw_1.nil? 
        	profil_name_panw_1 = @profil_panw_1.name
        	profil_price_panw_1 = (@profil_panw_1.price * @numero_panw_1)
        	profil_posotita_panw_1  = @numero_panw_1
        else
        	profil_name_panw_1 = ""
        	profil_price_panw_1 = 0
        	profil_posotita_panw_1 = 0
        end
        if !@profil_panw_2.nil? 
        	profil_name_panw_2 = @profil_panw_2.name
        	profil_price_panw_2 = (@profil_panw_2.price * @numero_panw_2)
        	profil_posotita_panw_2 =  @numero_panw_2
        else
        	profil_name_panw_2 = ""
        	profil_price_panw_2 = 0
        	profil_posotita_panw_2 = 0
        end
        if !@profil_panw_3.nil? 
        	profil_name_panw_3 = @profil_panw_3.name
        	profil_price_panw_3 = (@profil_panw_3.price * @numero_panw_3)
        	profil_posotita_panw_3 =  @numero_panw_3
        else
        	profil_name_panw_3 = ""
        	profil_price_panw_3 = 0
        	profil_posotita_panw_3 = 0
        end
        if !@profil_katw_1.nil? 
        	profil_name_katw_1 = @profil_katw_1.name
        	profil_price_katw_1 = (@profil_katw_1.price * @numero_katw_1)
        	profil_posotita_katw_1  = @numero_katw_1
        else
        	profil_name_katw_1 = ""
        	profil_price_katw_1 = 0
        	profil_posotita_katw_1 = 0
        end
        if !@profil_katw_2.nil? 
        	profil_name_katw_2 = @profil_katw_2.name
        	profil_price_katw_2 = (@profil_katw_2.price * @numero_katw_2)
        	profil_posotita_katw_2 =  @numero_katw_2
        else
        	profil_name_katw_2 = ""
        	profil_price_katw_2 = 0
        	profil_posotita_katw_2 = 0
        end
        if !@profil_katw_3.nil? 
        	profil_name_katw_3 = @profil_katw_3.name
        	profil_price_katw_3 = (@profil_katw_3.price * @numero_katw_3)
        	profil_posotita_katw_3 =  @numero_katw_3
        else
        	profil_name_katw_3 = ""
        	profil_price_katw_3 = 0
        	profil_posotita_katw_3 = 0
        end
        if !@typos_katw_1.nil? 
        	typos_name_katw_1 = @typos_katw_1.name
        	typos_price_katw_1 = (@typos_katw_1.price * @numero_typos_1)
        	typos_posotita_katw_1  = @numero_typos_1
        else
        	typos_name_katw_1 = ""
        	typos_price_katw_1 = 0
        	typos_posotita_katw_1 = 0
        end
        if !@typos_katw_2.nil? 
        	typos_name_katw_2 = @typos_katw_2.name
        	typos_price_katw_2 = (@typos_katw_2.price * @numero_typos_2)
        	typos_posotita_katw_2 =  @numero_typos_2
        else
        	typos_name_katw_2 = ""
        	typos_price_katw_2 = 0
        	typos_posotita_katw_2 = 0
        end
        if !@typos_katw_3.nil? 
        	typos_name_katw_3 = @typos_katw_3.name
        	typos_price_katw_3 = (@typos_katw_3.price * @numero_typos_3)
        	typos_posotita_katw_3 =  @numero_typos_3
        else
        	typos_name_katw_3 = ""
        	typos_price_katw_3 = 0
        	typos_posotita_katw_3 = 0
        end
        
        if  ( @profil_deksia.nil? && @profil_aristera.nil? && @profil_panw.nil? && @profil_katw.nil? )
        	profil_name = ""
        	profil_price = 0
        	profil_posotita = 0
        end
        		
        		
        	

	    respond_to do |format|
	      format.html { if current_user.admin == 1
		                  user = PseUser.where(:id => $pseUserId).first
		                  if ( user )
		                  	redirect_to etic_etic_pse_user_card_path(:id => $pseUserId) 
						  else
					        redirect_to(etic_card_path) 
					      end
					    else
					        redirect_to(etic_user_diax_path)
					    end 
	      	           }
          format.json { render json: {:arxiki_timi => @price,
                                      :epikathimeno => epik_rolo_name,
                                      :timi_epikathimenou => epik_rolo_price,
                                      :eksoteriko => ekso_rolo_name,
                                      :ekso_rolo_price => ekso_rolo_price,
                                      :persida_name => persida_name,
                                      :persida_price => persida_price, 
                                      :nea_timi => @price_new,
          	                          :teliki_timi => @price_sum,
          	                          :tzami => tzami_name,
          	                          :tzami_timi => tzami_timi,
          	                          :profil_name_deksia_1 => profil_name_deksia_1,
          	                          :profil_price_deksia_1 => profil_price_deksia_1,
          	                          :profil_posotita_deksia_1 => profil_posotita_deksia_1,
          	                          :profil_name_deksia_2 => profil_name_deksia_2,
          	                          :profil_price_deksia_2 => profil_price_deksia_2,
          	                          :profil_posotita_deksia_2 => profil_posotita_deksia_2,
          	                          :profil_name_deksia_3 => profil_name_deksia_3,
          	                          :profil_price_deksia_3 => profil_price_deksia_3,
          	                          :profil_posotita_deksia_3 => profil_posotita_deksia_3,
          	                          :profil_name_aristera_1 => profil_name_aristera_1,
          	                          :profil_price_aristera_1 => profil_price_aristera_1,
          	                          :profil_posotita_aristera_1 => profil_posotita_aristera_1,
          	                          :profil_name_aristera_2 => profil_name_aristera_2,
          	                          :profil_price_aristera_2 => profil_price_aristera_2,
          	                          :profil_posotita_aristera_2 => profil_posotita_aristera_2,
          	                          :profil_name_aristera_3 => profil_name_aristera_3,
          	                          :profil_price_aristera_3 => profil_price_aristera_3,
          	                          :profil_posotita_aristera_3 => profil_posotita_aristera_3,
          	                          :profil_name_panw_1 => profil_name_panw_1,
          	                          :profil_price_panw_1 => profil_price_panw_1,
          	                          :profil_posotita_panw_1 => profil_posotita_panw_1,
          	                          :profil_name_panw_2 => profil_name_panw_2,
          	                          :profil_price_panw_2 => profil_price_panw_2,
          	                          :profil_posotita_panw_2 => profil_posotita_panw_2,
          	                          :profil_name_panw_3 => profil_name_panw_3,
          	                          :profil_price_panw_3 => profil_price_panw_3,
          	                          :profil_posotita_panw_3 => profil_posotita_panw_3,
          	                          :profil_name_katw_1 => profil_name_katw_1,
          	                          :profil_price_katw_1 => profil_price_katw_1,
          	                          :profil_posotita_katw_1 => profil_posotita_katw_1,
          	                          :profil_name_katw_2 => profil_name_katw_2,
          	                          :profil_price_katw_2 => profil_price_katw_2,
          	                          :profil_posotita_katw_2 => profil_posotita_katw_2,
          	                          :profil_name_katw_3 => profil_name_katw_3,
          	                          :profil_price_katw_3 => profil_price_katw_3,
          	                          :profil_posotita_katw_3 => profil_posotita_katw_3,
          	                          :typos_name_katw_1 => typos_name_katw_1,
          	                          :typos_price_katw_1 => typos_price_katw_1,
          	                          :typos_posotita_katw_1 => typos_posotita_katw_1,
          	                          :typos_name_katw_2 => typos_name_katw_2,
          	                          :typos_price_katw_2 => typos_price_katw_2,
          	                          :typos_posotita_katw_2 => typos_posotita_katw_2,
          	                          :typos_name_katw_3 => typos_name_katw_3,
          	                          :typos_price_katw_3 => typos_price_katw_3,
          	                          :typos_posotita_katw_3 => typos_posotita_katw_3,
          	                          :odoigos_name => odoigos_name,
          	                          :odoigos_timi => odoigos_timi } }
        end
	end

	def save_image
		last = Order.order("created_at").last
		id = last.id + 1
		File.open("#{Rails.root}/public/upload/#{id}.png", 'wb') do |f|
          f.write(params[:image].read)
        end
	end

    ## Κάρτα απλού user. To @user_id το θέλω για το pdf. 
	def card 
      @items = Order.where(:user_id => current_user.id)
      @number = @items.count
      @sunolo = 0;
      @items.each do |i| #Γινεται και αυτοματα με το update γιατι ανανεονετε η σελιδα!!
        @sunolo = @sunolo + i.price_sum
      end
      @user_id = current_user.id
	end

    ## Περνάω ότι θέλω στο view του pdf. pdf.pdf.prawn. Pdf μονο για απλούς users.
	def pdf
		@user = User.where(:id => params[:id]).first
		@items = Order.where(:user_id => @user.id)
		@sunolo = 0;
        @items.each do |i| #Γινεται και αυτοματα με το update γιατι ανανεονετε η σελιδα!!
          @sunolo = @sunolo + i.price_sum
        end
        @user = User.where(:id => params[:id]).first
        @name = @user.name
        @surname = @user.epitheto
        @company = @user.company
        @address = @user.address1
        @phone = @user.phone
        @email = @user.email
		#redirect_to etic_home_path
	end

    ## Εξάγω την παραγγελία σε διάφωρα αρχεία. csv, xls, xml.
	def export
		@items = Order.where(:user_id => current_user.id)
		respond_to do |format|
          format.csv { filename = "SunGate-#{Time.now.strftime("Date:%d-%m-%Y ---Time:%H:%M:%S")}.csv"
                       send_data @items.to_csv, :filename => filename} ##render text: @items.to_csv
          format.xls { render text: @items.to_csv(col_sep: "\t") }
          format.xml { render xml: @items.to_xml, :only => [:id, :height, :width] }
        end 
	end

    require 'csv'
	##import απο το csv του wolf-sungate
	def import_terms
		#imp = CSV.read('#{Rails.root}/public/sungate_csv/terms-of-payments.csv', headers:true)
		termsss = CSV.foreach("#{Rails.root}/public/sungate_csv/terms-of-payments.csv", col_sep: ';', headers:true) do |row|
			term = Termsop.new
		    term.num = row['Id']
		    term.text = row['Text']
		    term.save
		end 
		redirect_to etic_user_diax_path
	end

	def import_sungate
		CSV.foreach("#{Rails.root}/public/sungate_csv/customers.csv", col_sep: ';', encoding: 'iso-8859-1') do |row|  ##, encoding: 'iso-8859-1'
			customer = SimpleUserPse.new
			if ( row[0] == "CUSTOMER" )
				customer.dealer_num = row[1]
				customer.cust_no = row[2]
				customer.mr = row[3]
				customer.name = row[4]
				customer.eponimo = row[5]
				customer.address = row[6]
				customer.city = row[7]
				customer.postal_code = row[8]
				customer.country_code = row[9]
				customer.phone = row[10]
				customer.mobile = row[11]
				customer.email = row[12]
				customer.fax = row[13]
                customer.save
			end
		end
		redirect_to etic_user_diax_path
	end

    ## Διαγράφω το επιλεγμένο κούφωμα. 
	def destroy
	  @item = Order.find(params[:id])
	  @item.destroy
	  if current_user.admin == 1
        redirect_to etic_etic_card_path
      else
      	redirect_to etic_user_diax_path
      end
    end

    ## Διαγράφω όλη την παραγγελία.
    def diagrafi
      @item = Order.where(:user_id => current_user.id)
      @item.each do |i|
        i.destroy
      end
      redirect_to etic_home_path
    end

    ## Κάνω update τον αριθμό του κουφώματος.
    def update
      @update = Order.where(:id => params[:id], :user_id => current_user.id).first # Οταν εχω δυο ιδια προιοντα με ιδιο artikel εχω λαθος γιατι ανανεωνει μονο το ενα!!! Θέλω έλεγχο
      @update_price = @update.price_update
      if ( params[:amount].to_i > 0)
        @update.posotoita = params[:amount].to_i
        @update.price_sum = ( @update_price * params[:amount].to_i )
        @update.save
      else
        @update.destroy
      end
    end

    def color_epistrofi 
  	  @color_epistrofi = Color.where(:name => params[:color]).first.code

  	  respond_to do |format|
        format.json { render json: @color_epistrofi.to_json}
      end
    end

    ######## User ########

    def user_diax
    	@pseudo = SimpleUserPse.where(:user_id => current_user.id)
    	if ( params[:istoriko] == "1")
    		@pseudo = SimpleUserPse.where(:user_id => params[:user])
    	end
    	@admin = current_user.admin
    	##########

    	user = User.where(:id => current_user.id).first
    	#@customers = SimpleUserPse.where(:user_id => user.id)
    	@customers = SimpleUserPse.where(:dealer_num => user.sungate_code)

    	@paraggelies = Paraggelia.where(:user => current_user.id)

    	sunolo = 0

        paraggelies_order = Paraggelia.all
            
        paraggelies_order.each do |i| 
        	offer = Order.where(:paraggelia_id => i.id).all
        	offer.each do |o| 
                sunolo = sunolo + o.price_sum 
            end
            i.sum = sunolo
            i.save
            sunolo = 0
        end 

       
    	if( !params[:customer].nil? )
            @paraggelies = Paraggelia.where(:customer => params[:customer]).order("created_at").reverse
    	end
    	if( params[:customer] == "0" )
            @paraggelies = Paraggelia.where(:user => current_user.id)
    	end

    
    	if(params[:order] == "price_low")
            @paraggelies = Paraggelia.where(:user => current_user.id).order("sum")
    	end
    	if(params[:order] == "price_high")
            @paraggelies = Paraggelia.where(:user => current_user.id).order("sum").reverse
    	end
    	if(params[:order] == "code_low")
            @paraggelies = Paraggelia.where(:user => current_user.id).order("id")
    	end
    	if(params[:order] == "code_high")
            @paraggelies = Paraggelia.where(:user => current_user.id).order("id").reverse
    	end
    	if(params[:order] == "date_old")
            @paraggelies = Paraggelia.where(:user => current_user.id).order("created_at")
    	end
    	if(params[:order] == "date_new")
            @paraggelies = Paraggelia.where(:user => current_user.id).order("created_at").reverse
    	end
    	if(params[:order] == "name_a")
    		@paraggelies = Paraggelia.where(:user => current_user.id).order("eponimo")
    	end
    	if(params[:order] == "name_z")
    		@paraggelies = Paraggelia.where(:user => current_user.id).order("eponimo").reverse
    	end
 
    end


    ## Σελίδα με φόρμα για δημιουργία νέου pseudoUser.
    def simple_user_cr
    end

    def select_customer
    	user = User.where(:id => current_user.id).first
    	#@customers = SimpleUserPse.where(:user_id => user.id)
    	@customers = SimpleUserPse.where(:dealer_num => user.sungate_code).order("eponimo")
    end

    def new_offer
    	offer = Paraggelia.new
    	offer.user = current_user.id
    	offer.customer = params[:customer_id]
    	eponimo_customer = SimpleUserPse.where(:id => params[:customer_id]).first
    	offer.eponimo = eponimo_customer.name
    	offer.save
    	redirect_to etic_simple_pse_user_path(:paraggelia_id => offer.id)
    end

    ## Δημιουργία νέου user. 
    def add_simple_user
  	  user = SimpleUserPse.new
 
  	  user.name  = params[:onoma]
  	  user.eponimo = params[:eponimo]
  	  user.company = params[:company]
  	  user.phone = params[:phone]
  	  user.email = params[:email]
  	  user.address = params[:address]
  	  user.user_id = current_user.id
  	  user.save
  	  if !user.new_record?
  	  	redirect_to etic_user_diax_path
  	  else
  	    redirect_to etic_simple_user_cr_path
  	  end
  	  #if( !params[:onoma].present? && !params[:eponimo].present? && !params[:company].present? && !params[:phone].present? && !params[:email].present? && !params[:address].present?)
    end

    ## Καλάθι των pseudoUser όταν μπαίνω σαν admin.
	def simple_pse_user_card
		#@user = SimpleUserPse.where(:id => params[:id]).first
		#@user_id = @user.id
        #   @items =  Order.where(:istoriko_id => @user.id) 
        #   @number = @items.count
        #   @sunolo = 0; 
        #     @items.each do |i| 
        #     @sunolo = @sunolo + i.price_sum 
        #  end 
        #@done = @user.done
        #@admin = params[:admin]
        @user = SimpleUserPse.where(:id => 1).first
		@paraggelia_id = params[:id]
            @items =  Order.where(:paraggelia_id => params[:id]) 
            @number = @items.count
            @sunolo = 0; 
              @items.each do |i| 
              @sunolo = @sunolo + i.price_sum 
           end 
        #@done = @user.done
        #@admin = params[:admin]
	end

	##Ολοκλήρωση παραγγελίας. Κάνω done τον simple user pses
	def oloklirwsi_simple_user_pses
		#user = SimpleUserPse.where(:id => params[:id]).first
        #user.done = 1
        #user.save
        #redirect_to etic_user_diax_path
        paraggelia = Paraggelia.where(:id => params[:id]).first
        paraggelia.done = 1
        paraggelia.save
        redirect_to etic_user_diax_path

	end

	## Διαγραφή παραγγελίας pseudoUser
    def diagrafi_simple_user
  	  @item = Order.where(:paraggelia_id => params[:id])
      @item.each do |i|
        i.destroy
      end
      paraggelia = Paraggelia.where(:id => params[:id]).first.destroy
      redirect_to etic_user_diax_path
    end

    ## Περνάω ότι θέλω στο view του pdf. pdf_simple_user.pdf.prawn.
    def pdf_simple_user
  	  @items = Order.where(:paraggelia_id => params[:id])
	  @sunolo = 0;
        @items.each do |i| #Γινεται και αυτοματα με το update γιατι ανανεονετε η σελιδα!!
          @sunolo = @sunolo + i.price_sum
        end
      paraggelia = Paraggelia.where(:id => params[:id]).first
      @user = SimpleUserPse.where(:id => paraggelia.customer).first
      @name = @user.name
      @surname = @user.eponimo
      @company = @user.company
      @address = @user.address
      @phone = @user.phone
      @email = @user.email
    end

    ## Εξάγω την παραγγελία σε διάφωρα αρχεία. csv, xls, xml.
    def export_simple_user
  	  @items = Order.where(:istoriko_id => params[:id])
	  respond_to do |format|
        format.csv { filename = "SunGate-#{Time.now.strftime("Date:%d-%m-%Y ---Time:%H:%M:%S")}.csv" 
                     send_data @items.to_csv, :filename => filename} ##render text: @items.to_csv
        format.xls { render text: @items.to_csv(col_sep: "\t") }
        format.xml { render xml: @items.to_xml, :only => [:id, :height, :width] }
       end 
    end

    ######## Admin ########
  
    ## Κύρια σελίδα του admin panel. Εμφανίζω admin και pdeudo.
    def etic_card
	  @user = User.all
	  @pseudo = PseUser.all
	end

    ## Καλάθι του user όταν μπαίνω σαν admin.
    def etic_user_card
      @user = User.where(:id => params[:id]).first
      @items =  Order.where(:user_id => @user.id) 
      @number = @items.count
      @sunolo = 0; 
           @items.each do |i| 
           @sunolo = @sunolo + i.price_sum 
        end 
        @user_id = params[:id]
    end

    ## Καλάθι των pseudoUser όταν μπαίνω σαν admin.
	def etic_pse_user_card
		@user = PseUser.where(:id => params[:id]).first
		@user_id = @user.id
           @items =  Order.where(:user_id => @user.id).where(:pse => 1) 
           @number = @items.count
           @sunolo = 0; 
             @items.each do |i| 
             @sunolo = @sunolo + i.price_sum 
          end 
	end

    ## Σελίδα με φόρμα για δημιουργία νέου pseudoUser.
    def new_user
    end

    ## Δημιουργία νέου user. 
    def add_user
  	  user = PseUser.new
 
  	  user.name  = params[:onoma]
  	  user.eponimo = params[:eponimo]
  	  user.company = params[:company]
  	  user.phone = params[:phone]
  	  user.email = params[:email]
  	  user.address = params[:address]
  	  user.save
  	  if !user.new_record?
  	  	#redirect_to etic_home_path(:pse_user => user.id)
  	  	redirect_to etic_etic_card_path
  	  else
  	    redirect_to etic_new_user_path
  	  end
  	  #if( !params[:onoma].present? && !params[:eponimo].present? && !params[:company].present? && !params[:phone].present? && !params[:email].present? && !params[:address].present?)
    end

    ## Διαγραφή παραγγελίας pseudoUser
    def diagrafi_admin
  	  @item = Order.where(:user_id => params[:id]).where(:pse => params[:pse])
      @item.each do |i|
        i.destroy
      end
      redirect_to etic_home_path
    end

    ## Update στην ποσότητα των κουφωμάτων της κάρτας του pseudoUser.
    def update_admin
  	  @update = Order.where(:id => params[:id]).first # Οταν εχω δυο ιδια προιοντα με ιδιο artikel εχω λαθος γιατι ανανεωνει μονο το ενα!!! Θέλω έλεγχο
      @update_price = @update.price_update
      if ( params[:amount].to_i > 0)
        @update.posotoita = params[:amount].to_i
        @update.price_sum = ( @update_price * params[:amount].to_i )
        @update.save
      else
        @update.destroy
      end
    end

    ## Εξάγω την παραγγελία σε διάφωρα αρχεία. csv, xls, xml.
    def export_admin
  	  @items = Order.where(:user_id => params[:id], :pse => params[:pse])
	  respond_to do |format|
        format.csv { filename = "SunGate-#{Time.now.strftime("Date:%d-%m-%Y ---Time:%H:%M:%S")}.csv" 
                     send_data @items.to_csv, :filename => filename} ##render text: @items.to_csv
        format.xls { render text: @items.to_csv(col_sep: "\t") }
        format.xml { render xml: @items.to_xml, :only => [:id, :height, :width] }
       end 
    end

    ## Περνάω ότι θέλω στο view του pdf. pdf_admin.pdf.prawn. Pdf μονο για pseudoUsers.
    def pdf_admin
  	  @items = Order.where(:user_id => params[:id], :pse => params[:pse])
	  @sunolo = 0;
        @items.each do |i| #Γινεται και αυτοματα με το update γιατι ανανεονετε η σελιδα!!
          @sunolo = @sunolo + i.price_sum
        end
      @user = PseUser.where(:id => params[:id]).first
      @name = @user.name
      @surname = @user.eponimo
      @company = @user.company
      @address = @user.address
      @phone = @user.phone
      @email = @user.email
    end

    ## Αλλάζω την τιμή done στην βάση. Αν ολοκληρώθηκε την κάνω 1.
    def pse_done
      @user = PseUser.where(:id => params[:pse_user]).first
      if (params[:pse] == "0")
        @user = User.where(:id => params[:pse_user]).first
      end
      if params[:done] == '1'
        @user.done  = 1
      else
        @user.done  = 0
      end
      @user.save
      redirect_to etic_etic_card_path
    end


end



