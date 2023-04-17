class PagesController < ApplicationController
	def home
			render json: {
				status: "SUCCESS",
				message: "Rendering CV",
				data: {
					name: 'Ulises Tirado Zatarain',
					emails: [
						'u*****o@gmail.com',
						'u*****o@cimat.mx',
					],
					phones: [
						'+44 07 (516) XXX XXX',
						'+52 1 (669) XXX XXXX',
					],
					websites: [
						'https://github.com/zatarain',
					],
					statement: '',
					experiences: [

					],
					qualifications: [

					],
					projects: [

					],
					skills: [

					],
					awards: [

					],
					volunteering: [

					]
				},
			}, status: :ok
	end
end
