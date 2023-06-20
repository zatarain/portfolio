import Image from 'next/image';
import Link from 'next/link'
import styles from './index.module.css'

interface Properties {
	name: string
}

function toggleResponsive(event: any) {
	console.log('Yay! Click!')
	console.dir(event)
}

const NavigationBar = ({ name }: Properties) => {
	return (
		<nav className={styles['navigation-bar']}>
			<Link href="/" className={styles.logo}>
				<Image alt="logo" src="/logo.svg" width="48" height="48" />
				{name}
			</Link>
			<ul className={styles.sections}>
				<li><Link href="#">Experience</Link></li>
				<li><Link href="#">Education</Link></li>
				<li><Link href="#">Skills</Link></li>
				<li><Link href="#">Projects</Link></li>
				<li><Link href="#">Hobbies</Link></li>
				<li className={styles.action}><Link href="#">E-mail</Link></li>
				<li className={styles.action}>
					<Link href="#" onClick={toggleResponsive} className={styles['call-to-action']}>Download</Link>
				</li>
				<li className={styles.icon}>
					<Link href="#">
						<i className="fa fa-bars"></i>
					</Link>
				</li>
			</ul>
		</nav>
	)
}

export default NavigationBar
