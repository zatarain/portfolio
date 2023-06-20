import Image from 'next/image';
import Link from 'next/link'

interface Properties {
	name: string
}

const NavigationBar = ({ name }: Properties) => {
	return (
		<nav>
			<Link href="/" className="logo">
				<Image alt="logo" src="/logo.svg" width="48" height="48" />
				{name}
			</Link>
			<div className="sections">
				<Link href="#">Experience</Link>
				<Link href="#">Education</Link>
				<Link href="#">Skills</Link>
				<Link href="#">Projects</Link>
				<Link href="#">Hobbies</Link>
			</div>
			<div className="actions">
				<Link href="#">E-mail</Link>
				<Link href="#" className="call-to-action">Download</Link>
			</div>
		</nav>
	)
}

export default NavigationBar
